class Inspection < ActiveRecord::Base
	self.primary_key = :id
	belongs_to :premise
	has_many   :infractions

	def has_critical_infractions?
		infractions.any? { |i| i.infraction_type == 'CRITICAL' }
	end

	def has_minor_infractions?
		infractions.any? { |i| i.infraction_type == 'MINOR' }
	end

	def critical_infractions
		infractions.where(infraction_type: 'CRITICAL').count
	end

	def minor_infractions
		infractions.where(infraction_type: 'MINOR').count
	end

	def set_details
		crit_count = 0
		minor_count = 0

		self.details = ''
		self.details_short = ''

		# TODO - Test self.
		infractions.each do |i|
			crit_count += 1  if i.infraction_type == 'CRITICAL'
			minor_count += 1 if i.infraction_type == 'MINOR'
		end

		if crit_count == 0 and minor_count == 0
			self.details = ''
			self.details_short = 'P'
		elsif crit_count > 0
			self.details = "#{crit_count} Critical Infraction"
			self.details += 's' if crit_count > 1
			self.details_short = "#{crit_count}C"
		end
		if minor_count > 0
			unless self.details.empty?
				self.details += ', '
				self.details_short += ' '
			end
			self.details += "#{minor_count} Minor Infraction"
			self.details += 's' if minor_count > 1
			self.details_short += "#{minor_count}M"
		end

	end
end
