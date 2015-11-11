class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    pars = {}
    pars[:sort] = params[:sort] || session[:sort]
    pars[:ratings] = params[:ratings] || session[:ratings]
    if not params[:sort] and session[:sort] or not params[:ratings] and session[:ratings]
      redirect_to movies_path(pars) if not pars.empty?
    end
    
    @all_ratings = Movie.get_ratings
    
    if params[:sort] == 'title'
      @sort_by = :title
      @hilite_title = 'hilite'
    elsif params[:sort] == 'release_date'
      @sort_by = :release_date
      @hilite_release_date = 'hilite'
    end
    
    @ratings_checked = {}
    @sort_by_title_with_params = { sort: 'title'}
    @sort_by_date_with_params = { sort: 'release_date'}
    
    if params[:ratings]
      where_clause = {rating: params[:ratings].keys}
      
      @sort_by_title_with_params.merge!(:ratings => params[:ratings])
      @sort_by_date_with_params.merge!(:ratings => params[:ratings])
      
      @all_ratings.each { |k, v| @ratings_checked[k] = params[:ratings].keys.include?(k) }
    else
      @all_ratings.each { |k, v| @ratings_checked[k] = true }
    end
    
    @movies = Movie.all.where(where_clause).order(@sort_by)
    
    session[:sort] = @sort_by if @sort_by
    session[:ratings] = params[:ratings]
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
