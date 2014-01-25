class Premise < ActiveRecord::Base
	has_many :inspections, -> { order(date: :desc) }

	self.primary_key = :id
	self.per_page = 50

	# Get all the premise types as an array of strings
	def self.get_types
		types = ActiveRecord::Base.connection.execute("SELECT DISTINCT premise_type FROM premises")
    	types.map { |t| t[0] }
	end

	def self.search(type, name, page)
		if type.nil? or type.empty?
			premises = Premise.where("name LIKE ? AND inspections.result IS NOT NULL", "%#{name}%")
		else
			premises = Premise.where("name LIKE ? AND premise_type = ? AND inspections.result IS NOT NULL", "%#{name}%", type)
		end
		premises.includes(inspections: [:infractions]).paginate(:page => page).order(:name)
	end
end
