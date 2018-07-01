class ReportSettingsController < ApplicationController

  def index
    @year,@month = params[:year] || Time.now.year,params[:month] || Time.now.month
    @setting = ReportSetting.where(year:@year,month:@month).first
    @setting ||= ReportSetting.new(year:@year,month:@month)
  end

  def new_leader_requirment
    respond_to do |format|
      format.js
    end
  end

  def save_report_setting
    rs_params = report_setting_set
    unless params[:id].blank?
      rs = ReportSetting.find(params[:id])
    else
      rs = ReportSetting.new year: rs_params[:year],month:rs_params[:month]
    end
    rs.update_attributes yml_data: rs_params.to_h.reject{|k,_| [:id,:year,:month].include?(k.to_sym)}.to_yaml
    render js:"alert('保存成功!');location.reload();"
  end

  def copy_last_month_set
    year,month = params[:year_and_month].split('-')
    if month.to_i == 1
      last_year,last_month = year.to_i - 1,12
    else
      last_year,last_month = year,month.to_i-1
    end
    last_set = ReportSetting.where(year:last_year,month:last_month).first
    if last_set.blank?
      return render js:"alert('上月无设置!');"
    end
    now_set = ReportSetting.where(year:year,month:month).first
    now_set ||= ReportSetting.new year:year,month:month
    now_set.update_attributes yml_data:last_set.yml_data
    render js:"alert('设置成功!');location.reload();"
  end

  protected
  def report_setting_set
    params.require(:set).permit(:id,:year,:month,new_leader:{},old_leader:{},manager:{},sale:{},leaders:[:leader_id,:requirment])
  end
end