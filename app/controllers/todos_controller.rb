class TodosController < ApplicationController
  before_action :set_todo, only: %i[ show edit update destroy ]

  # GET /todos or /todos.json
  def index
    @todos = Todo.order(created_at: :desc)
  end

  # GET /todos/1 or /todos/1.json
  def show
  end

  # GET /todos/new
  def new
    @todo = Todo.new
  end

  # GET /todos/1/edit
  def edit
  end

  # POST /todos or /todos.json
  def create
    @todo = Todo.new(todo_params)

    respond_to do |format|
      if @todo.save
        flash.now[:notice] = "Todo created at #{Time.zone.now.strftime('%H:%M:%S - %b %e,  %Y')}"
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new-todo', partial: 'todos/form', locals: { todo: Todo.new }),
            turbo_stream.prepend('todos', partial: 'todos/todo', locals: { todo: @todo }),
            turbo_stream.prepend('flash', partial: 'layouts/flash')
          ]
        end
        format.html { redirect_to todo_url(@todo), notice: "Todo was successfully created." }
        format.json { render :show, status: :created, location: @todo }
      else
        flash.now[:alert] = "Todo was not created - #{@todo.errors.first.full_message}"
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new-todo', partial: 'todos/form', locals: { todo: @todo }),
            turbo_stream.prepend('flash', partial: 'layouts/flash')
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todos/1 or /todos/1.json
  def update
    respond_to do |format|
      if @todo.update(todo_params)
        format.html { redirect_to todo_url(@todo), notice: "Todo was successfully updated." }
        format.json { render :show, status: :ok, location: @todo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todos/1 or /todos/1.json
  def destroy
    @todo.destroy

    respond_to do |format|
      flash.now[:notice] = "Todo #{@todo.id} was successfully removed"
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend('flash', partial: 'layouts/flash'),
          turbo_stream.remove("todo_#{@todo.id}")
        ]
      end
      format.html { redirect_to todos_url, notice: "Todo was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def todo_params
      params.require(:todo).permit(:title)
    end
end
