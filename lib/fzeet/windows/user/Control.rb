if __FILE__ == $0
	require 'ffi'

	# FIXME: dirty fix to propagate FFI structs layout down the inheritance hierarchy
	# TODO: switch to composition instead inheriting FFI structs
	module PropagateFFIStructLayout
		def inherited(child_class)
			child_class.instance_variable_set '@layout', layout
		end
	end

	class FFI::Struct
		def self.inherited(child_class)
			child_class.extend PropagateFFIStructLayout
		end
	end
	# END FIXME
end

if __FILE__ == $0
	require_relative 'Window/Common'
end
require_relative 'Control/Button'
require_relative 'Control/Static'
require_relative 'Control/Edit'
require_relative 'Control/ListBox'
require_relative 'Control/ComboBox'
