class AttendancesController < ApplicationController
  before_filter :check_admin

  def create
    params.permit!
    @attendance = Attendance.new(params[:id])
    @attendance.save
    render json: @attendance
  end

  def destroy
    @attendance = Attendance.find(params[:id])
    if @attendance.delete
      redirect_to attendance_mission_path(@attendance.mission.id)
    else
      flash[:error] = "Could not delete attendance!"
      redirect_to attendance_mission_path(@attendance.mission.id)
    end
  end
end
