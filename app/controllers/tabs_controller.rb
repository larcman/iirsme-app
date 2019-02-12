class TabsController < ApplicationController

  def get_research_tabs
    research_id = params[:research_id]
    @tabs = Tab.all_research_tabs(research_id)
    respond_to do |format|
      format.js { render partial: 'research_tabs/get_research_tabs', tabs: @tabs }
    end
  end

  def add_research_tab
    research_id = params[:research_id]
    name = params[:name]

    if name.blank?
      @title = "El nombre es necessario para agregar una nueva Solapa"
      @is_error = true
      respond_to do |format|
        format.js { render partial: 'researches/wizard/messages'}
      end
      return
    end

    @tab = Tab.new(name: name, research_id: research_id, seq_no: Tab.get_next_seqno(research_id))
    if @tab.save
      @tabs = Tab.all_research_tabs(research_id)
      respond_to do |format|
        format.js { render partial: 'research_tabs/refresh_research_tabs', tabs: @tabs }
      end
      return
    else
      @title = @tab.errors.messages[:name][0]
      @is_error = true
      respond_to do |format|
        format.js { render partial: 'researches/wizard/messages'}
      end
      return 
    end
  end

  def delete_research_tab
    research_id = params[:research_id]
    tab_id = params[:tab_id]
    tab = Tab.where(id: tab_id).first
    tab.destroy
    respond_to do |format|
      @tabs = Tab.all_research_tabs(research_id)
      format.js { render partial: 'research_tabs/refresh_research_tabs', tabs: @tabs }
    end
  end

end