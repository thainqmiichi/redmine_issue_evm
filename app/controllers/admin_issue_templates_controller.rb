class AdminIssueTemplatesController < ApplicationController
  layout 'admin'
  before_action :require_admin
  before_action :find_template, only: [:update, :destroy]

  def index
    @templates = IssueTemplate.order(:id)
    @template = IssueTemplate.new
  end

  def create
    @template = IssueTemplate.new(template_params)
    if @template.save
      redirect_to admin_issue_templates_path, notice: 'Success!'
    else
      @templates = IssueTemplate.order(:id)
      render :index
    end
  end

  def edit
    @template = IssueTemplate.find(params[:id])
  end

  def update
    if @template.update(template_params)
      redirect_to admin_issue_templates_path, notice: 'Success!'
    else
      render :edit
    end
  end

  def destroy
    @template.destroy
    redirect_to admin_issue_templates_path, notice: 'Success!'
  end

  private

  def require_admin
    render_403 unless User.current.admin?
  end

  def find_template
    @template = IssueTemplate.find(params[:id])
  end

  def template_params
    params.require(:issue_template).permit(:name, :tracker_id, :subject, :description)
  end
end
