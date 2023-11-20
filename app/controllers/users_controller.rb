# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update]

  def index
    @current_user = Current.user
    @users = User.all
    @attachments = ActiveStorage::Attachment.where(record: User.all)
    @attachments = search(@attachments) if params[:commit]
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:notice] = 'User was updated successfully.'
      redirect_to users_path
    else
      render 'edit'
    end
  end

  def remove_attachment
    @file = ActiveStorage::Attachment.find(params[:id])
    @file.purge_later
    redirect_back fallback_location: users_path
  end

  def download
    @attachments = ActiveStorage::Attachment.where(record: User.all)
    @attachments = search(@attachments) if params[:created_from].present? || params[:created_to].present?
    pdf = AttachmentPdf.new(@attachments)
    send_data(pdf.render,
              filename: 'filename.pdf',
              type: 'application/pdf')
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(files: [])
  end

  def search(attachments)
    @filtered_attachments = attachments
    if params['created_from'].present?
      @filtered_attachments = @filtered_attachments.where('created_at > ?', params['created_from'].to_datetime)
    end

    if params['created_to'].present?
      @filtered_attachments = @filtered_attachments.where('created_at < ?', params['created_to'].to_datetime)
    end

    @filtered_attachments
  end
end
