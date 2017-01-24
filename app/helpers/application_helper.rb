module ApplicationHelper

  def format_date(depart_at: depart_at, return_at: return_at)
    departure_date = "#{date.strftime('%B').downcase} #{date.strftime('%e').downcase}"
    return_date = trip.return_at.strftime('%e')
    if trip.return_at.strftime('%B') != trip.depart_at.strftime('%B')
      return_date.prepend("#{trip.return_at.strftime('%B').downcase} ")
    end
    return "#{departure_date}-#{return_date}"
  end
end
