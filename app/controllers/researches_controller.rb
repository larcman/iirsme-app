class ResearchesController < ApplicationController
  before_action :require_user
  before_action :set_research, only: [:edit, :update, :show, :destroy]
  before_action :set_current_research, except: [:back]
  before_action only: [:edit, :update, :destroy] do
    require_owner(@research)
  end
  before_action only: [:show] do
    require_research_user(@research)
  end

  def enter_research
    # render plain: params.inspect
    seq_no = ""
    params.each do |key, value|
      if key.start_with?("seqno_")
        seq_no = value
      end
    end
    id = params["id_" + seq_no]
    password = params["password_" + seq_no]

    @research = Research.find(id)
    if @research.is_private
      if !@research.correct_password?(password)
        flash[:danger] = "Contraseña incorrecta"
        redirect_to home_path and return
      elsif !@research.authorized_user?(current_user)
        flash[:danger] = "Acceso denegado, favor de contactar al administrador del protocolo"
        redirect_to home_path and return
      end
    end
    redirect_to research_path(@research)
  end

  def show
  end

  def new
    @current_step = 1
    @research = Research.new
  end

  def create
    @current_step = 1
    @research = Research.new(research_params) 
    if @research.save
      # flash[:success] = "Protocolo creado satisfactoriamente"
      redirect_to edit_research_path(@research)
    else
      render 'new'
    end
  end

  def edit
    @current_step = 1
    @current_view = 'research-setup'
  end

  def update
    @current_step = 1
    params = research_params
    params.delete(:password) if params[:password] == Research::TEMP_PASSWORD
    if @research.update(params)
      redirect_to edit_research_path(@research)
    else
      render 'edit'
    end
  end
  
  def back
    research = params[:research]
    go_home = true?(params[:go_home])
    if go_home
      redirect_to home_path
    else
      @current_research = Research.find(research)
      redirect_to research_path(@current_research)
    end
  end

  private
  def set_research
    @research = Research.find(params[:id])
  end
  def set_current_research
    @current_research = @research
  end
  def research_params
    params.require(:research).permit(:code, :name, :description, :is_private, :password, :registration_code, :owner_id)
  end

end