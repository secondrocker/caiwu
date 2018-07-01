class Team < ApplicationRecord
  belongs_to :team_set
  has_many :team_sales,dependent: :destroy
  has_many :sales,through: :team_sales
  belongs_to :leader, foreign_key: 'leader_id',class_name: 'Sale'
  enum level:{leader:2,manager:3,director:4}
  LEVELS={leader: '主管',manager: '经理',director: '总监'}
  enum leader_type:{new_leader:1,old_leader:2}
  LEADER_TYPES = {new_leader: '新主管',old_leader: '老主管'}
  def level_text
    Team::LEVELS[self.level.to_sym]
  end

  def leader_type_text
    return nil if self.leader_type.blank?
    Team::LEADER_TYPES[self.leader_type.to_sym] if self.leader?
  end

  def left_sales_options
    Sale.where('id <> ? and not exists(select 1 from team_sales,teams b where b.id = team_sales.team_id and
b.team_set_id = ? and team_sales.sale_id = sales.id )',self.leader_id,self.team_set_id).select('id,name,alias_name').map{|x| [x.full_name,x.id]}
  end

  def update_sales(sales_ids)
    sales_ids ||= []
    self.team_sales.each{|x| x.destroy unless sales_ids.map(&:to_i).include?(x.sale_id)}
    sales_ids.map(&:to_i).each do |sale_id|
      self.team_sales.create sale_id: sale_id unless self.sales.map(&:id).include?(sale_id)
    end
  end

  #获取名下所有销售员
  def get_sales
    case self.level
      when 'leader'
        self.sales
      when 'manager'
        self.sales + self.team_set.teams.select{|x| self.sales.map(&:id).include?(x.leader_id) }.map(&:get_sales).flatten
      when 'director'
        self.sales + self.team_set.teams.select{|x| self.sales.map(&:id).include?(x.leader_id) }.map(&:get_sales).flatten
    end
  end
end
