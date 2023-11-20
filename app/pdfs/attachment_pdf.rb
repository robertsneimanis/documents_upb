# frozen_string_literal: true

class AttachmentPdf < Prawn::Document
  def initialize(attachments)
    super()
    @attachments = attachments
    text 'Attachments', size: 25, align: :center
    line_items
  end

  def line_items
    move_down 20
    table line_item_rows
  end

  def line_item_rows
    data = []
    @attachments.each do |item|
      data << [
        item.filename.to_s,
        item.created_at.strftime('%d/%m/%Y %H:%M').to_s,
        item.content_type.to_s
      ]
    end

    [['Filename', 'Created at', 'Attachment type']] + data
  end
end
