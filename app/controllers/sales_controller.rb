class SalesController < ApplicationController
  before_action :load_sale,only:[:destroy,:show,:edit,:update]
  layout false, only:[:new,:edit]
  def index
    @sales = Sale.paginate(per_page: 15,page: params[:page]).order('created_at desc')
    respond_to do |format|
     format.html
    end
  end

  def new
    @sale ||= Sale.new
    respond_to do |format|
      format.html
    end
  end

  def edit
  end

  def destroy
    @sale.destroy
    render js:"alert('删除成功!');location.reload();"
  end

  def create
    Sale.create sale_param
    render js:"alert('新增成功!');$('#brow_edit_sale').remove();location.reload();"
  end

  def update
    @sale.update_attributes sale_param
    render js:"alert('修改成功!');$('#brow_edit_sale').remove();location.reload();"
  end



  protected
  def load_sale
    @sale = Sale.find params[:id]
  end
  def sale_param
    params.require(:sale).permit(:name, :level,:leader_type,:new_leader,:alias_name)
  end
end
