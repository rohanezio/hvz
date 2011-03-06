class GamesController < ApplicationController
	before_filter :check_admin, :only => ['new', 'create', 'edit', 'update']

	def index
		@games = Game.all
	end

	def show
		@game = Game.find(params[:id])
		@players = @game.registrations.sort{ |x,y| y.score <=> x.score }
		
#		if not fragment_exist?(:action => "show", :action_suffix => "gamestats", :id => @game.id)	
			states = @players.map{|x| x.state_history}
			tslength = ((@current_game.game_ends - @current_game.game_begins) / 240).floor
			data = {}
			240.times do |dt|
				now = @current_game.game_begins + (dt.seconds.to_i*tslength)
				data[now] = {:zombies => 0, :deceased => 0, :humans=>0}
				states.each do |s|
					# States is a hash of important times of players. Like
					# state = {:human => [time became human], :zombie => [time zombified], 
					#          :deceased => [time of death]}
					# So, determining who is at which state is now pretty easy.
					if s[:human] <= now
						if s[:zombie] <= now
							if s[:deceased] <= now
								data[now][:deceased] += 1
								next
							end
							data[now][:zombies] += 1
							next
						end
						data[now][:humans] += 1
					end
				end
			end
			@human_v_time = data.map{|x,y| [(x - @current_game.game_begins)/1.hour, y[:humans]]}
			@zombie_v_time = data.map{|x,y| [(x - @current_game.game_begins)/1.hour, y[:zombies]]}
			@deceased_v_time = data.map{|x,y| [(x - @current_game.game_begins)/1.hour, y[:deceased]]}
#		end
	end
	
	def rules
		@game = Game.find(params[:id]) || @current_game
	end

	def new
		@game = Game.new
	end

	def edit
		@game = Game.find(params[:id])
		unless params[:game].nil?
			@game = Game.new(params[:game])
		end
	end

	def create
		@game = Game.new(params[:game])
		if Game.current.id.nil?
			@game.is_current = true
		end

		if @game.save()
			redirect_to :action => :index
		else
			flash[:message] = @game.errors.full_messages.first
			redirect_to :action => :new
		end
	end

	def update
		@game = Game.find(params[:id])
		if @game.update_attributes(params[:game])
			redirect_to :action => :edit
		else
			flash[:error] = @game.errors.full_messages.first
			render :action => :edit
		end
	end
end