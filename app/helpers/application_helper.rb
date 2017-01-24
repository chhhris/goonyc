module ApplicationHelper

  def format_date(depart_at: depart_at, return_at: return_at)
    departure_date = "#{depart_at.strftime('%B').downcase} #{depart_at.strftime('%e').downcase}"
    return_date = return_at.strftime('%e')
    if return_at.strftime('%B') != depart_at.strftime('%B')
      return_date.prepend("#{return_at.strftime('%B').downcase} ")
    end
    return "#{departure_date}-#{return_date}"
  end
end
