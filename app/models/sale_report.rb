require 'spreadsheet'
class SaleReport < ApplicationRecord

  def hash_data
    YAML.load self.data_yml
  end

  class << self
    def export_tao_details(sale_name,details)
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet :name => "#{sale_name}套数明细"
      sheet.row(0).replace(%w{销售员 分单员 客户姓名 项目名称 认购日期 签约日期 结佣标准 优惠 优惠已扣 优惠未扣 分单比例 套数 })
      details.each_with_index do |detail,i|
        sheet.row(i+1).replace([detail[:name],detail[:other_sales],detail[:customer_name],detail[:project_name],
                                detail[:sub_date],detail[:order_date],detail[:commision_price],detail[:reduce_price],
                                detail[:reduced_price],detail[:no_reduced_price],detail[:rate].to_s+'%',detail[:tao].round(4)])
      end
      path = "/tao_detail_export/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xls"
      book.write(Rails.root.to_s + '/public' + path)
      path
    end

    def export_amount_details(sale_name,details)
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet :name => "#{sale_name}套数明细"
      sheet.row(0).replace(%w{销售员 分单员 客户姓名 项目名称 认购日期 签约日期 结佣标准 优惠 优惠已扣 优惠未扣 分单比例 签约额 })
      details.each_with_index do |detail,i|
        sheet.row(i+1).replace([detail[:name],detail[:other_sales],detail[:customer_name],detail[:project_name],
                                detail[:sub_date],detail[:order_date],detail[:commision_price],detail[:reduce_price],
                                detail[:reduced_price],detail[:no_reduced_price],detail[:rate].to_s+'%',detail[:amount].round(4)])
      end
      path = "/tao_detail_export/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xls"
      book.write(Rails.root.to_s + '/public' + path)
      path
    end

    def export_sale_pay_details(sale_name,details)
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet :name => "#{sale_name}提成明细"
      sheet.row(0).replace(%w{销售员 分单员 客户姓名 项目名称 认购日期 签约日期 实际提成 提点 套数 个人提成 实发 留存 工资})
      details.each_with_index do |detail,i|
        sheet.row(i+1).replace([detail[:name],detail[:other_sales],detail[:customer_name],detail[:project_name],
                                detail[:sub_date],detail[:order_date],detail[:daiti_money].to_f.round(4),detail[:rate].to_f.round(4),
                                detail[:tao].to_f.round(4),detail[:ti_money].to_f.round(4),detail[:real_money].to_f.round(4),detail[:left_money].to_f.round(4),
                               detail[:real_money].to_f.round(4)])
      end
      path = "/tao_detail_export/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xls"
      book.write(Rails.root.to_s + '/public' + path)
      path
    end

    def export_leader_pay_details(sale_name,details)
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet :name => "#{sale_name}提成明细"
      sheet.row(0).replace(%w{销售员 分单员 客户姓名 项目名称 认购日期 签约日期 实际提成 提点 套数 个人提成 主管提点 主管工资})
      details.each_with_index do |detail,i|
        sheet.row(i+1).replace([detail[:name],detail[:other_sales],detail[:customer_name],detail[:project_name],
                                detail[:sub_date],detail[:order_date],detail[:daiti_money].to_f.round(4),detail[:rate].to_f.round(4),
                                detail[:tao].to_f.round(4),detail[:ti_money].to_f.round(4),detail[:leader_ti_rate].to_f.round(4),detail[:leader_ti_money].to_f.round(4)])
      end
      path = "/tao_detail_export/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xls"
      book.write(Rails.root.to_s + '/public' + path)
      path
    end


    def export_manager_pay_details(sale_name,details)
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet :name => "#{sale_name}提成明细"
      sheet.row(0).replace(%w{销售员 分单员 客户姓名 项目名称 认购日期 签约日期 实际提成 提点 套数 个人提成 主管提点 主管工资 经理提点 经理工资})
      details.each_with_index do |detail,i|
        sheet.row(i+1).replace([detail[:name],detail[:other_sales],detail[:customer_name],detail[:project_name],
                                detail[:sub_date],detail[:order_date],detail[:daiti_money].to_f.round(4),detail[:rate].to_f.round(4),
                                detail[:tao].to_f.round(4),detail[:ti_money].to_f.round(4),detail[:leader_ti_rate].to_f.round(4),detail[:leader_ti_money].to_f.round(4),
                                detail[:manager_ti_rate].to_f.round(4),detail[:manager_ti_money].to_f.round(4)])
      end
      path = "/tao_detail_export/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xls"
      book.write(Rails.root.to_s + '/public' + path)
      path
    end


    def export_director_pay_details(sale_name,details)
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet :name => "#{sale_name}提成明细"
      sheet.row(0).replace(%w{销售员 分单员 客户姓名 项目名称 认购日期 签约日期 实际提成 提点 套数 个人提成 主管提点 主管工资 经理提点 经理工资 总监提点 总监工资})
      details.each_with_index do |detail,i|
        sheet.row(i+1).replace([detail[:name],detail[:other_sales],detail[:customer_name],detail[:project_name],
                                detail[:sub_date],detail[:order_date],detail[:daiti_money].to_f.round(4),detail[:rate].to_f.round(4),
                                detail[:tao].to_f.round(4),detail[:ti_money].to_f.round(4),detail[:leader_ti_rate].to_f.round(4),detail[:leader_ti_money].to_f.round(4),
                                detail[:manager_ti_rate].to_f.round(4),detail[:manager_ti_money].to_f.round(4),detail[:director_ti_rate].to_f.round(4),detail[:director_ti_money].to_f.round(4)])
      end
      path = "/tao_detail_export/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xls"
      book.write(Rails.root.to_s + '/public' + path)
      path
    end
  end
end
