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

require_relative 'comdlg/FileDialog'
require_relative 'comdlg/ShellFileDialog' if Fzeet::Windows::Version >= :vista
require_relative 'comdlg/FontDialog'
require_relative 'comdlg/ColorDialog'
require_relative 'comdlg/FindReplaceDialog'
require_relative 'comdlg/PrintDialog'
