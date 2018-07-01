class TeamSet < ApplicationRecord
  has_many :teams,dependent: :destroy

  def left_team_leaders_options
    Sale.where('not exists(select 1 from teams where team_set_id = ? and leader_id = sales.id)',
               self.id ).map{|x| [x.full_name,x.id]}
  end

  def clone_team_set
    new_team_set = TeamSet.create self.attributes.reject{|k,_| k.to_sym == :id}
    self.teams.each do |x|
      new_team = new_team_set.teams.create(x.attributes.reject{|k,_| [:id,:team_set_id].include?(k.to_sym)})
      x.team_sales.each do |team_sale|
        new_team.team_sales.create(team_sale.attributes.reject{|k,_| [:id,:team_id].include?(k.to_sym)})
      end
    end
  end
  class << self
    def get_set_sales(s_time,e_time)
      tses = TeamSet.where('(start_time <= :s_time and end_time >= :e_time) or (:s_time between start_time and end_time) or
   (:e_time between start_time and end_time) or (start_time>= :s_time and end_time <= :e_time)',s_time:s_time,e_time:e_time)
      tses.map do |ts|
        _start_time,_end_time = [s_time,ts.start_time.beginning_of_day].max,[e_time,ts.end_time.end_of_day].min
        sales = (ts.teams.map(&:leader) + ts.teams.map{|t| t.sales}.flatten).uniq
        leader_teams = ts.teams.select{|x| x.leader?}
        manager_teams = ts.teams.select{|x| x.manager?}
        director_teams = ts.teams.select{|x| x.director?}
        leaders = ts.teams.select{|x| x.level == :director}.map(&:leader)
        {
            start_time:_start_time,
            end_time:_end_time,
            sales:sales,
            leaders:leader_teams.map{|x| [x.leader,x.get_sales.map(&:id)]},
            managers:manager_teams.map{|x|[x.leader,x.get_sales.map(&:id)]},
            directors:director_teams.map{|x|[x.leader,x.get_sales.map(&:id)]}
        }
      end
    end

    def get_leader(sale_id,order_date)
      ts = TeamSet.where('? between start_time and date_sub(end_time,interval - 86399  second)',order_date).first
      leader_team = Team.where('level = 2 and team_set_id = ? and exists(select 1 from team_sales where sale_id = ? and team_id = teams.id)',ts.id,sale_id).first
      leader_team.blank? ? nil : leader_team
    end

    def get_manager(sale_id,order_date)
      ts = TeamSet.where('? between start_time and date_sub(end_time,interval - 86399  second)',order_date).first
      leader_team = Team.where('level = 2 and team_set_id = ? and exists(select 1 from team_sales where sale_id = ? and team_id = teams.id)',ts.id,sale_id).first
      manager_team = Team.where('level = 3 and team_set_id = ? and exists(select 1 from team_sales where sale_id = ? and team_id = teams.id)',ts.id,leader_team.blank? ? sale_id : leader_team.leader_id).first
      manager_team.blank? ? nil : manager_team
    end

    def get_director(sale_id,order_date)
      ts = TeamSet.where('? between start_time and date_sub(end_time,interval - 86399  second)',order_date).first
      leader_team = Team.where('level = 2 and team_set_id = ? and exists(select 1 from team_sales where sale_id = ? and team_id = teams.id)',ts.id,sale_id).first
      manager_team = Team.where('level = 3 and team_set_id = ? and exists(select 1 from team_sales where sale_id = ? and team_id = teams.id)',ts.id,leader_team.blank? ? sale_id : leader_team.leader_id).first
      director_team = Team.where('level = 4 and team_set_id = ? and exists(select 1 from team_sales where sale_id = ? and team_id = teams.id)',ts.id,manager_team.blank? ? (leader_team.blank? ? sale_id : leader_team.leader_id) : manager_team.leader_id).first
      director_team.blank? ? nil : director_team
    end

    def calc_data(year,month)
      _time = Time.local(year,month)
      s_time,e_time = _time.beginning_of_month,_time.end_of_month
      orders = Order.where('sub_date between  ? and ? ',s_time,e_time).includes([:orders_sales,:subscription,:payments])
      sales_set_hash = TeamSet.get_set_sales(s_time,e_time)
      all_sales = sales_set_hash.map{|x| x[:sales]}.flatten.uniq
      full_hash = {}
      full_hash[:taos] = calc_sales_tao(all_sales,orders)
      full_hash[:subs] = calc_sales_sub(all_sales,orders)
      full_hash[:leader_subs] = calc_leaders_sub(sales_set_hash,full_hash)
      full_hash[:manager_subs] = calc_managers_sub(sales_set_hash,full_hash)
      full_hash[:director_subs] = calc_directors_sub(sales_set_hash,full_hash)
      full_hash[:sale_pays] = calc_sales_pay(all_sales,s_time,e_time,full_hash)
      full_hash[:leader_pays] = calc_leader_pay(s_time,e_time,full_hash)
      full_hash[:manager_pays] = calc_manager_pay(s_time,e_time,full_hash)
      full_hash[:director_pays] = calc_director_pay(s_time,e_time,full_hash)
      report = SaleReport.where(year:year,month:month).first
      report ||= SaleReport.new(year:year,month:month)
      report.update_attributes data_yml:full_hash.to_yaml
    end

    #计算套数
    def calc_sales_tao(sales,orders)
      tao_hash = {}
      sales.each do |sale|
        _orders = orders.select{|x| x.customer_type == 0 and x.sales.map(&:id).include?(sale.id)}
        sale_hash = {sale.id.to_s => {details:[],sum:{sale_id:sale.id,name: sale.full_name}}}
        _orders.each do |_order|
          _sale_order = _order.orders_sales.detect{|x| x.sale_id == sale.id}
          _other_sales = _order.sales.reject{|x| x.id == sale.id}
          sale_hash[sale.id.to_s][:details] << {
              name:sale.full_name,
              other_sales:_other_sales.map(&:full_name).join(','),
              customer_name:_order.customer_name,
              project_name:_order.project_name,
              sub_date:_order.subscription.blank? ?  '' : _order.subscription.sub_date.strftime('%Y-%m-%d'),
              order_date:_order.sub_date.strftime('%Y-%m-%d'),
              commision_price:_order.commision_price,
              reduce_price:_order.reduce_price,
              reduced_price:_order.reduced_price,
              no_reduced_price:_order.no_reduced_price,
              rate:_sale_order.rate,
              tao:(_order.commision_price - _order.reduce_price.to_f)/_order.commision_price*_sale_order.rate/100
          }
        end
        sale_hash[sale.id.to_s][:sum][:tao] = sale_hash[sale.id.to_s][:details].map{|x| x[:tao]}.sum
        tao_hash.merge! sale_hash
      end
      tao_hash
    end

    #计算签约额
    def calc_sales_sub(sales,orders)
      sub_hash = {}
      sales.each do |sale|
        _orders = orders.select{|x| x.sales.map(&:id).include?(sale.id)}
        sale_hash = {sale.id.to_s => {details:[],sum:{sale_id:sale.id,name: sale.full_name}}}
        _orders.each do |_order|
          _sale_order = _order.orders_sales.detect{|x| x.sale_id == sale.id}
          _other_sales = _order.sales.reject{|x| x.id == sale.id}
          sale_hash[sale.id.to_s][:details] << {
              name:sale.full_name,
              other_sales:_other_sales.map(&:full_name).join(','),
              customer_name:_order.customer_name,
              project_name:_order.project_name,
              sub_date:_order.subscription.blank? ?  '' : _order.subscription.sub_date.strftime('%Y-%m-%d'),
              order_date:_order.sub_date.strftime('%Y-%m-%d'),
              commision_price:_order.commision_price,
              reduce_price:_order.reduce_price,
              reduced_price:_order.reduced_price,
              no_reduced_price:_order.no_reduced_price,
              rate:_sale_order.rate,
              amount:(_order.commision_price - _order.reduce_price.to_f)*_sale_order.rate/100
          }
        end
        sale_hash[sale.id.to_s][:sum][:amount] = sale_hash[sale.id.to_s][:details].map{|x| x[:amount]}.sum
        sub_hash.merge! sale_hash
      end
      sub_hash
    end

    def calc_leaders_sub(sales_set_hash,full_hash)
      leader_sub = {}
      sales_set_hash.each do |set_hash|
        _start_time,_end_time = set_hash[:start_time],set_hash[:end_time]
        set_hash[:leaders].each do |leader_set|
          leader,sales_ids = leader_set
          sales_ids << leader.id
          leader_sub[leader.id.to_s] ||= {}
          leader_sub[leader.id.to_s][:details] ||= []
          leader_sub[leader.id.to_s][:details] += full_hash[:subs].select{|k,v| sales_ids.include?(k.to_i)}.map{|k,v| v[:details]}.flatten.select{|d| _start_time <= d[:order_date] && _end_time >= d[:order_date]}
        end
        leader_sub.each do |k,v|
          leader = Sale.find(k)
          leader_sub[leader.id.to_s][:sum] = {leader_id:leader.id,name:leader.full_name,amount:leader_sub[leader.id.to_s][:details].map{|x| x[:amount].to_f}.sum}
        end
      end
      leader_sub
    end
    def calc_managers_sub(sales_set_hash,full_hash)
      manager_sub = {}
      sales_set_hash.each do |set_hash|
        _start_time,_end_time = set_hash[:start_time],set_hash[:end_time]
        set_hash[:managers].each do |manager_set|
          manager,sales_ids = manager_set
          sales_ids << manager.id
          manager_sub[manager.id.to_s] ||= {}
          manager_sub[manager.id.to_s][:details] ||= []
          manager_sub[manager.id.to_s][:details] += full_hash[:subs].select{|k,v| sales_ids.include?(k.to_i)}.map{|k,v| v[:details]}.flatten.select{|d| _start_time <= d[:order_date] && _end_time >= d[:order_date]}
        end
        manager_sub.each do |k,v|
          manager = Sale.find(k)
          manager_sub[manager.id.to_s][:sum] = {manager_id:manager.id,name:manager.full_name,amount:manager_sub[leader.id.to_s][:details].map{|x| x[:amount].to_f}.sum}
        end
      end
      manager_sub
    end

    def calc_directors_sub(sales_set_hash,full_hash)
      director_sub = {}
      sales_set_hash.each do |set_hash|
        _start_time,_end_time = set_hash[:start_time],set_hash[:end_time]
        set_hash[:directors].each do |director_set|
          director,sales_ids = director_set
          sales_ids << director.id
          director_sub[director.id.to_s] ||= {}
          director_sub[director.id.to_s][:details] ||= []
          director_sub[director.id.to_s][:details] += full_hash[:subs].select{|k,v| sales_ids.include?(k.to_i)}.map{|x| x[:details]}.flatten.select{|d| _start_time <= d[:order_date] && _end_time >= d[:order_date]}
        end
        director_sub.each do |k,v|
          director = Sale.find(k)
          director_sub[director.id.to_s][:sum] = {director_id:director.id,name:director.full_name,amount:director_sub[director.id.to_s][:details].map{|x| x[:amount].to_f}.sum}
        end
      end
      director_sub
    end

    #计算销售员提成
    def calc_sales_pay(sales,start_time,end_time,full_hash)
      set = ReportSetting.where(year:start_time.year,month:start_time.month).first.sets
      pays = Payment.where('pay_date between ? and ? ',start_time,end_time).includes([:order])
      sale_hash = {}
      sales.each do |sale|
        sale_hash[sale.id.to_s] = {details:[],sum:{sale_id:sale.id,name:sale.full_name}}
        _pays = pays.select{|x| x.order.sales.map(&:id).include?(sale.id)}
        _pays.each do |_pay|
          _order = _pay.order
          _order_date = _order.sub_date
          amount = [_order.payments.select{|x| x.pay_date <= _pay.pay_date}.map(&:money).sum - _order.reduce_price.to_f,_pay.money].min
          next if amount <= 0
          sub_sale = _order.orders_sales.detect{|x| x.sale_id == sale.id}
          other_sale_name = _order.orders_sales.select{|x| x.sale_id != sale.id}.map{|x| x.sale.full_name}.join(',')
          if _order_date >= start_time && _order_date <= end_time
            _set = set
            _full_hash = full_hash
          else
            _set = ReportSetting.where(year:_order_date.year,month:_order_date.month).first.sets
            _full_hash = SaleReport.where(year:_order_date.year,month:_order_date.month).first.hash_data
          end
          tidian = _full_hash[:taos][sale.id.to_s][:sum][:tao] >= _set[:sale][:cover_num].to_f ? _set[:sale][:rebate_max].to_f/100 : _set[:sale][:rebate_min].to_f/100
          sale_hash[sale.id.to_s][:details] << {
              name:sale.full_name,
              other_name:other_sale_name,
              customer_name:_order.customer_name,
              project_name:_order.project_name,
              sub_date:_order.subscription.try(:sub_date),
              order_date:_order_date,
              daiti_money:amount,
              tao:sub_sale.rate.to_f/100,
              rate:tidian,
              ti_money:amount*sub_sale.rate.to_f/100*tidian,
              leader_ti_rate:0,
              leader_ti_money:0,
              manager_ti_rate:0,
              manager_ti_money:0,
              director_ti_rate:0,
              director_ti_money:0,
              real_money:amount*sub_sale.rate.to_f/100*tidian*0.9,
              left_money:amount*sub_sale.rate.to_f/100*tidian*0.1}
        end
        sale_hash[sale.id.to_s][:sum][:daiti_money] = sale_hash[sale.id.to_s][:details].map{|x| x[:daiti_money]}.sum
        sale_hash[sale.id.to_s][:sum][:ti_money] = sale_hash[sale.id.to_s][:details].map{|x| x[:ti_money]}.sum
        sale_hash[sale.id.to_s][:sum][:real_money] = sale_hash[sale.id.to_s][:details].map{|x| x[:real_money]}.sum
        sale_hash[sale.id.to_s][:sum][:left_money] = sale_hash[sale.id.to_s][:details].map{|x| x[:left_money]}.sum
      end
      sale_hash
    end

    #主管提成
    def calc_leader_pay(start_time,end_time,full_hash)
      set = ReportSetting.where(year:start_time.year,month:start_time.month).first.sets
      leader_hash = {}
      full_hash[:sale_pays].each do |sale_id,sale_hash|
        sale_hash[:details].each do |pay_hash|
          team = TeamSet.get_leader(sale_id,pay_hash[:order_date])
          next if team.blank?
          if pay_hash[:order_date] >= start_time && pay_hash[:order_date] <= end_time
            _set = set
            _full_hash = full_hash
          else
            _set = ReportSetting.where(year:pay_hash[:order_date].year,month:pay_hash[:order_date].month).first.sets
            _full_hash = SaleReport.where(year:pay_hash[:order_date].year,month:pay_hash[:order_date].month).first.hash_data
          end
          leader = team.leader
          _requirment = _set[:leaders].detect{|x| x[:leader_id].to_i == leader.id}[:requirment].to_f*10000
          _done_amount =  _full_hash[:leader_subs][leader.id.to_s][:sum][:amount].to_f
          if team.new_leader?
            _rate = _done_amount >= _requirment ? _set[:new_leader][:rebate_max].to_f/100 : set[:new_leader][:rebate_rate].to_f/100
          else
            _rate = _done_amount >= _requirment ? _set[:old_leader][:rebate_max].to_f/100 : set[:old_leader][:rebate_rate].to_f/100
          end
          pay_hash[:leader_ti_rate] = _rate
          pay_hash[:leader_ti_money] = _rate * (pay_hash[:daiti_money].to_f*pay_hash[:tao].to_f - pay_hash[:ti_money].to_f)
          leader_hash_detail = pay_hash.clone
          leader_hash[leader.id.to_s] ||= {}
          leader_hash[leader.id.to_s][:details] ||= []
          leader_hash[leader.id.to_s][:details] << leader_hash_detail
        end
      end
      leader_hash.each do |leader_id,_hash|
        leader = Sale.find(leader_id)
        leader_hash[leader_id.to_s][:sum] = {leader_id:leader_id,name:leader.full_name,money:leader_hash[leader_id.to_s][:details].map{|x| x[:leader_ti_money].to_f}.sum}
      end
      leader_hash
    end

    #经理提成
    def calc_manager_pay(start_time,end_time,full_hash)
      set = ReportSetting.where(year:start_time.year,month:start_time.month).first.sets
      manager_hash = {}
      full_hash[:sale_pays].each do |sale_id,sale_hash|
        sale_hash[:details].each do |pay_hash|
          team = TeamSet.get_manager(sale_id,pay_hash[:order_date])
          next if team.blank?
          if pay_hash[:order_date] >= start_time && pay_hash[:order_date] <= end_time
            _set = set
            _full_hash = full_hash
          else
            _set = ReportSetting.where(year:pay_hash[:order_date].year,month:pay_hash[:order_date].month).first.sets
            _full_hash = SaleReport.where(year:pay_hash[:order_date].year,month:pay_hash[:order_date].month).first.hash_data
          end
          manager = team.leader
          _requirment = _set[:leaders].detect{|x| x[:leader_id].to_i == manager.id}[:requirment].to_f*10000
          _done_amount =  _full_hash[:manager_subs][manager.id.to_s][:sum][:amount].to_f
          _rate = _done_amount >= _requirment ? _set[:manager][:rebate_max].to_f/100 : _set[:manager][:rebate_rate].to_f/100
          pay_hash[:manager_ti_rate] = _rate
          pay_hash[:manager_ti_money] = _rate * (pay_hash[:daiti_money].to_f*pay_hash[:tao].to_f - pay_hash[:ti_money].to_f - pay_hash[:leader_ti_money].to_f)
          manager_hash_detail = pay_hash.clone
          manager_hash[manager.id.to_s] ||= {}
          manager_hash[manager.id.to_s][:details] ||= []
          manager_hash[manager.id.to_s][:details] << manager_hash_detail
        end
      end
      manager_hash.each do |manager_id,_hash|
        manager = Sale.find(manager_id)
        manager_hash[manager_id.to_s][:sum] = {manager_id:manager_id,name:manager.full_name,money:manager_hash[manager_id.to_s][:details].map{|x| x[:manager_ti_money].to_f}.sum}
      end
      manager_hash
    end

    #总监提成
    def calc_director_pay(start_time,end_time,full_hash)
      set = ReportSetting.where(year:start_time.year,month:start_time.month).first.sets
      director_hash = {}
      full_hash[:sale_pays].each do |sale_id,sale_hash|
        sale_hash[:details].each do |pay_hash|
          team = TeamSet.get_director(sale_id,pay_hash[:order_date])
          next if team.blank?
          if pay_hash[:order_date] >= start_time && pay_hash[:order_date] <= end_time
            _set = set
            _full_hash = full_hash
          else
            _set = ReportSetting.where(year:pay_hash[:order_date].year,month:pay_hash[:order_date].month).first.sets
            _full_hash = SaleReport.where(year:pay_hash[:order_date].year,month:pay_hash[:order_date].month).first.hash_data
          end
          director = team.leader
          _rate = pay_hash[:manager_ti_money].to_f == 0 ? 0.05 : 0.03
          pay_hash[:director_ti_rate] = _rate
          pay_hash[:director_ti_money] = _rate * (pay_hash[:daiti_money].to_f*pay_hash[:tao].to_f - pay_hash[:ti_money].to_f - pay_hash[:leader_ti_money].to_f - pay_hash[:director_ti_money])
          director_hash_detail = pay_hash.clone
          director_hash[director.id.to_s] ||= {}
          director_hash[director.id.to_s][:details] ||= []
          director_hash[director.id.to_s][:details] << director_hash_detail
        end
      end
      director_hash.each do |director_id,_hash|
        director = Sale.find(director_id)
        director_hash[director_id.to_s][:sum] = {director_id:director_id,name:director.full_name,money:director_hash[director_id.to_s][:details].map{|x| x[:director_ti_money].to_f}.sum}
      end
      director_hash
    end


  end
end
