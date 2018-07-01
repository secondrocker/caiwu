class TeamSetsController < ApplicationController
  before_action :load_team_set,only:[:update,:destroy]
  def index
    @team_sets = TeamSet.paginate(per_page: 20,page: params[:page]).order('end_time desc')
  end

  def create
    @team_set = TeamSet.create(team_set_param)
    render js:"alert('创建成功!');location.reload();"
  end

  def update
    @team_set.update_attributes(team_set_param)
    render js:"alert('修改成功!');location.reload();"
  end

  def destroy
    @team_set.destroy
    render js:"alert('删除成功!');location.reload();"
  end

  def create_team
    return render js:"alert('请选择领导!');" if team_params[:leader_id].blank?
    @team = Team.create team_params
    render js:"alert('创建成功!');location.reload();"
  end

  def delete_team
    @team = Team.find params[:id]
    @team.destroy
    render js:"alert('删除成功!');location.reload();"
  end

  def team_sales
    @team_set = TeamSet.find(params[:team_set_id])
    respond_to do |format|
      format.html
    end
  end

  def show_edit_team_sales
    @team = Team.find params[:id]
    respond_to do |format|
      format.js
    end
  end

  def save_team_sales
    @team = Team.find(team_sales_params[:team_id])
    @team.update_sales(team_sales_params[:sales_ids])
    render js:"alert('编辑成功!');location.reload();"
  end

  def clone_team_set
    TeamSet.find_by_id(params[:team_set_id]).clone_team_set
    render js:"alert('复制成功!');location.reload();"
  end

  protected

  def load_team_set
    @team_set = TeamSet.find(params[:id])
  end

  def team_set_param
    params.require(:team_set).permit(:start_time, :end_time)
  end

  def team_params
    params.require(:team).permit(:leader_id,:level,:leader_type).merge(params.permit(:team_set_id))
  end

  def team_sales_params
    params.permit(:team_id,sales_ids:[])
  end
end