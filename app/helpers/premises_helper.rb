module PremisesHelper
	def result_class( i )
		rc = ''
		if i.result == 'Passed'
			rc = 'passed'
		elsif i.result == 'Fail'
			rc = 'failed'
		elsif i.result == 'Conditional Pass'
			rc = 'conditional'
		end
		return rc
	end
end
