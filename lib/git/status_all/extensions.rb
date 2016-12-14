

class String
	def append(s)
		self + s
	end

	def pad_to_col(n)
		pad_amount = n - self.uncolorize.length
		return " " + s if pad_amount < 0
		return self + (" " * pad_amount)
	end

	def right_align(s)
		pad_amount = self._term_width - self.uncolorize.length - s.uncolorize.length
		return " " + s if pad_amount < 0
		return self + (" " * pad_amount) + s
	end

	def _term_width
		@term_width ||= `tput cols`.to_i
	end
end
