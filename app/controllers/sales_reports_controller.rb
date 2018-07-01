class SalesReportsController < ApplicationController
  require 'will_paginate/array'
  def sub_report
    params[:year] ||= Time.now.year
    params[:month] ||= Time.now.month
    if params[:commit] == '重新计算'
      TeamSet.calc_data(params[:year],params[:month])
    end
    @sr = SaleReport.where(year:params[:year],month:params[:month]).first
    if @sr.blank?
      @sales = []
    else
      @sales = @sr.hash_data[:taos].map{|_,v|v[:sum]}.paginate(per_page:20,page:params[:page])
    end
  end

  def sub_report_detail
    sale_id =params[:sale_id]
    sale = Sale.find(sale_id)
    sr = SaleReport.find(params[:report_id])
    @all_details = sr.hash_data[:taos][sale_id.to_s][:details]
    @details = @all_details.paginate(per_page:20,page:params[:page])
    if params[:export].present?
      return redirect_to SaleReport.export_tao_details(sale.full_name,@all_details)
    end
  end

  def sub_price_report
    params[:year] ||= Time.now.year
    params[:month] ||= Time.now.month
    @sr = SaleReport.where(year:params[:year],month:params[:month]).first
    if @sr.blank?
      @sales = []
    else
      @sales = @sr.hash_data[:subs].map{|_,v|v[:sum]}.paginate(per_page:20,page:params[:page])
    end
  end

  def sub_price_report_detail
    sale_id =params[:sale_id]
    sale = Sale.find(sale_id)
    sr = SaleReport.find(params[:report_id])
    @all_details = sr.hash_data[:subs][sale_id.to_s][:details]
    @details = @all_details.paginate(per_page:20,page:params[:page])
    if params[:export].present?
      return redirect_to SaleReport.export_amount_details(sale.full_name,@all_details)
    end
  end

  def sale_pay_report
    params[:year] ||= Time.now.year
    params[:month] ||= Time.now.month
    @sr = SaleReport.where(year:params[:year],month:params[:month]).first
    if @sr.blank?
      @sales = []
    else
      @sales = @sr.hash_data[:sale_pays].map{|_,v|v[:sum]}.flatten.paginate(per_page:20,page:params[:page])
    end
  end

  def sale_pay_report_detail
    sale_id = params[:sale_id]
    @sale = Sale.find(sale_id)
    sr = SaleReport.find(params[:report_id])
    @all_details = sr.hash_data[:sale_pays][sale_id.to_s][:details]
    @details = @all_details.paginate(per_page:20,page:params[:page])
    if params[:export].present?
      return redirect_to SaleReport.export_sale_pay_details(@sale.full_name,@all_details)
    end
  end

  def leader_pay_report
    params[:year] ||= Time.now.year
    params[:month] ||= Time.now.month
    @sr = SaleReport.where(year:params[:year],month:params[:month]).first
    if @sr.blank?
      @sales = []
    else
      @sales = @sr.hash_data[:leader_pays].map{|_,v|v[:sum]}.flatten.paginate(per_page:20,page:params[:page])
    end
  end

  def leader_pay_report_detail
    sale_id = params[:sale_id]
    @sale = Sale.find(sale_id)
    sr = SaleReport.find(params[:report_id])
    @all_details = sr.hash_data[:leader_pays][sale_id.to_s][:details]
    @details = @all_details.paginate(per_page:20,page:params[:page])
    if params[:export].present?
      return redirect_to SaleReport.export_leader_pay_details(@sale.full_name,@all_details)
    end
  end

  def manager_pay_report
    params[:year] ||= Time.now.year
    params[:month] ||= Time.now.month
    @sr = SaleReport.where(year:params[:year],month:params[:month]).first
    if @sr.blank?
      @sales = []
    else
      @sales = @sr.hash_data[:manager_pays].map{|_,v|v[:sum]}.flatten.paginate(per_page:20,page:params[:page])
    end
  end

  def manager_pay_report_detail
    sale_id = params[:sale_id]
    @sale = Sale.find(sale_id)
    sr = SaleReport.find(params[:report_id])
    @all_details = sr.hash_data[:manager_pays][sale_id.to_s][:details]
    @details = @all_details.paginate(per_page:20,page:params[:page])
    if params[:export].present?
      return redirect_to SaleReport.export_manager_pay_details(@sale.full_name,@all_details)
    end
  end

  def director_pay_report
    params[:year] ||= Time.now.year
    params[:month] ||= Time.now.month
    @sr = SaleReport.where(year:params[:year],month:params[:month]).first
    if @sr.blank?
      @sales = []
    else
      @sales = @sr.hash_data[:director_pays].map{|_,v|v[:sum]}.flatten.paginate(per_page:20,page:params[:page])
    end
  end

  def director_pay_report_detail
    sale_id = params[:sale_id]
    @sale = Sale.find(sale_id)
    sr = SaleReport.find(params[:report_id])
    @all_details = sr.hash_data[:director_pays][sale_id.to_s][:details]
    @details = @all_details.paginate(per_page:20,page:params[:page])
    if params[:export].present?
      return redirect_to SaleReport.export_director_pay_details(@sale.full_name,@all_details)
    end
  end

end