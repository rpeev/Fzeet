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

require_relative 'ole'
require_relative 'oleaut'
require_relative 'shell'

module Fzeet
	module Windows
		ffi_lib 'uiribbon'
		ffi_convention :stdcall

		def LoadRibbonDll(name = File.basename($0, '.rbw'), opts = {})
			path = File.dirname(File.expand_path($0))

			if !File.exist?("#{path}/#{name}.dll") || (
					File.exist?("#{path}/#{name}.xml") &&
					test(?M, "#{path}/#{name}.xml") > test(?M, "#{path}/#{name}.dll")
				)

				opts[:sdkroot] ||= "#{ENV['SystemDrive']}/Program Files/Microsoft SDKs/Windows/v7.1"
				opts[:vcroot] ||= "#{ENV['ProgramFiles']}/Microsoft Visual Studio 10.0/VC"
				#opts[:mingwroot] ||= "#{ENV['SystemDrive']}/MinGW"

				opts[:uicc] ||= "#{opts[:sdkroot]}/bin/uicc.exe"
				opts[:rc] ||= "#{opts[:sdkroot]}/bin/rc.exe"
				opts[:vcvars] ||= "#{opts[:vcroot]}/bin/vcvars32.bat"
				opts[:link] ||= "#{opts[:vcroot]}/bin/link.exe"
				#opts[:windres] ||= "#{opts[:mingwroot]}/bin/windres.exe"
				#opts[:gcc] ||= "#{opts[:mingwroot]}/bin/gcc.exe"

				opts[:clean] = true if opts[:clean].nil?

				raise 'Building the Ribbon requires Windows SDK and VC.' unless
					[:uicc, :rc, :vcvars, :link].all? { |tool| File.exist?(opts[tool]) }
				#raise 'Building the Ribbon requires Windows SDK and MinGW.' unless
				#	[:uicc, :windres, :gcc].all? { |tool| File.exist?(opts[tool]) }

				system <<-CMD
@echo off &\
 "#{opts[:uicc]}" "#{name}.xml" "#{name}.bml" /header:"#{name}.h" /res:"#{name}.rc" > "#{name}.log" &\
 "#{opts[:rc]}" /nologo /fo"#{ENV['TEMP']}/#{name}.res" "#{name}.rc" >> "#{name}.log" &\
 call "#{opts[:vcvars]}" >> "#{name}.log" &\
 "#{opts[:link]}" /nologo /machine:x86 /dll /noentry /out:"#{name}.dll" "#{ENV['TEMP']}/#{name}.res" >> "#{name}.log"
				CMD
#				system <<-CMD
#@echo off &\
# "#{opts[:uicc]}" "#{name}.xml" "#{name}.bml" /header:"#{name}.h" /res:"#{name}.rc" > "#{name}.log" &\
# "#{opts[:windres]}" -o"#{ENV['TEMP']}/#{name}.o" "#{name}.rc" >> "#{name}.log" &\
# "#{opts[:gcc]}" -shared -o"#{name}.dll" "#{ENV['TEMP']}/#{name}.o" >> "#{name}.log"
#				CMD

				raise "Ribbon build failed - see #{path}/#{name}.log for details." if File.read("#{path}/#{name}.log") =~ /error/i

				File.open("#{path}/#{name}.rb", 'w') { |rb|
					rb.puts "# Generated by the UIRibbon build, do NOT modify\n\n"

					File.foreach("#{path}/#{name}.h") { |line|
						rb.puts "#{$1[0].upcase}#{$1[1..-1]} = #{$2}" if line =~ /^\s*#define\s+(\w+)\s+(\d+)/
					}
				}

				%w{bml h rc}.each { |ext|
					File.delete("#{path}/#{name}.#{ext}") if File.exist?("#{path}/#{name}.#{ext}")
				} if opts[:clean]
			end

			require "#{path}/#{name}"

			raise "LoadLibrary('#{path}/#{name}.dll') failed." if
				(hdll = LoadLibrary("#{path}/#{name}.dll")).null?

			hdll.tap { at_exit { FreeLibrary(hdll) } }
		end

		module_function :LoadRibbonDll

		UI_PKEY_Enabled = PROPERTYKEY[VT_BOOL, 1]
		UI_PKEY_LabelDescription = PROPERTYKEY[VT_LPWSTR, 2]
		UI_PKEY_Keytip = PROPERTYKEY[VT_LPWSTR, 3]
		UI_PKEY_Label = PROPERTYKEY[VT_LPWSTR, 4]
		UI_PKEY_TooltipDescription = PROPERTYKEY[VT_LPWSTR, 5]
		UI_PKEY_TooltipTitle = PROPERTYKEY[VT_LPWSTR, 6]
		UI_PKEY_LargeImage = PROPERTYKEY[VT_UNKNOWN, 7]
		UI_PKEY_LargeHighContrastImage = PROPERTYKEY[VT_UNKNOWN, 8]
		UI_PKEY_SmallImage = PROPERTYKEY[VT_UNKNOWN, 9]
		UI_PKEY_SmallHighContrastImage = PROPERTYKEY[VT_UNKNOWN, 10]

		UI_PKEY_CommandId = PROPERTYKEY[VT_UI4, 100]
		UI_PKEY_ItemsSource = PROPERTYKEY[VT_UNKNOWN, 101]
		UI_PKEY_Categories = PROPERTYKEY[VT_UNKNOWN, 102]
		UI_PKEY_CategoryId = PROPERTYKEY[VT_UI4, 103]
		UI_PKEY_SelectedItem = PROPERTYKEY[VT_UI4, 104]
		UI_PKEY_CommandType = PROPERTYKEY[VT_UI4, 105]
		UI_PKEY_ItemImage = PROPERTYKEY[VT_UNKNOWN, 106]

		UI_PKEY_BooleanValue = PROPERTYKEY[VT_BOOL, 200]
		UI_PKEY_DecimalValue = PROPERTYKEY[VT_DECIMAL, 201]
		UI_PKEY_StringValue = PROPERTYKEY[VT_LPWSTR, 202]
		UI_PKEY_MaxValue = PROPERTYKEY[VT_DECIMAL, 203]
		UI_PKEY_MinValue = PROPERTYKEY[VT_DECIMAL, 204]
		UI_PKEY_Increment = PROPERTYKEY[VT_DECIMAL, 205]
		UI_PKEY_DecimalPlaces = PROPERTYKEY[VT_UI4, 206]
		UI_PKEY_FormatString = PROPERTYKEY[VT_LPWSTR, 207]
		UI_PKEY_RepresentativeString = PROPERTYKEY[VT_LPWSTR, 208]

		UI_PKEY_FontProperties = PROPERTYKEY[VT_UNKNOWN, 300]
		UI_PKEY_FontProperties_Family = PROPERTYKEY[VT_LPWSTR, 301]
		UI_PKEY_FontProperties_Size = PROPERTYKEY[VT_DECIMAL, 302]
		UI_PKEY_FontProperties_Bold = PROPERTYKEY[VT_UI4, 303]
		UI_PKEY_FontProperties_Italic = PROPERTYKEY[VT_UI4, 304]
		UI_PKEY_FontProperties_Underline = PROPERTYKEY[VT_UI4, 305]
		UI_PKEY_FontProperties_Strikethrough = PROPERTYKEY[VT_UI4, 306]
		UI_PKEY_FontProperties_VerticalPositioning = PROPERTYKEY[VT_UI4, 307]
		UI_PKEY_FontProperties_ForegroundColor = PROPERTYKEY[VT_UI4, 308]
		UI_PKEY_FontProperties_BackgroundColor = PROPERTYKEY[VT_UI4, 309]
		UI_PKEY_FontProperties_ForegroundColorType = PROPERTYKEY[VT_UI4, 310]
		UI_PKEY_FontProperties_BackgroundColorType = PROPERTYKEY[VT_UI4, 311]
		UI_PKEY_FontProperties_ChangedProperties = PROPERTYKEY[VT_UNKNOWN, 312]
		UI_PKEY_FontProperties_DeltaSize = PROPERTYKEY[VT_UI4, 313]

		UI_PKEY_RecentItems = PROPERTYKEY[VT_ARRAY | VT_UNKNOWN, 350]
		UI_PKEY_Pinned = PROPERTYKEY[VT_BOOL, 351]

		UI_PKEY_Color = PROPERTYKEY[VT_UI4, 400]
		UI_PKEY_ColorType = PROPERTYKEY[VT_UI4, 401]
		UI_PKEY_ColorMode = PROPERTYKEY[VT_UI4, 402]
		UI_PKEY_ThemeColorsCategoryLabel = PROPERTYKEY[VT_LPWSTR, 403]
		UI_PKEY_StandardColorsCategoryLabel = PROPERTYKEY[VT_LPWSTR, 404]
		UI_PKEY_RecentColorsCategoryLabel = PROPERTYKEY[VT_LPWSTR, 405]
		UI_PKEY_AutomaticColorLabel = PROPERTYKEY[VT_LPWSTR, 406]
		UI_PKEY_NoColorLabel = PROPERTYKEY[VT_LPWSTR, 407]
		UI_PKEY_MoreColorsLabel = PROPERTYKEY[VT_LPWSTR, 408]
		UI_PKEY_ThemeColors = PROPERTYKEY[VT_VECTOR | VT_UI4, 409]
		UI_PKEY_StandardColors = PROPERTYKEY[VT_VECTOR | VT_UI4, 410]
		UI_PKEY_ThemeColorsTooltips = PROPERTYKEY[VT_VECTOR | VT_LPWSTR, 411]
		UI_PKEY_StandardColorsTooltips = PROPERTYKEY[VT_VECTOR | VT_LPWSTR, 412]

		UI_PKEY_Viewable = PROPERTYKEY[VT_BOOL, 1000]
		UI_PKEY_Minimized = PROPERTYKEY[VT_BOOL, 1001]
		UI_PKEY_QuickAccessToolbarDock = PROPERTYKEY[VT_UI4, 1002]

		UI_PKEY_ContextAvailable = PROPERTYKEY[VT_UI4, 1100]

		UI_PKEY_GlobalBackgroundColor = PROPERTYKEY[VT_UI4, 2000]
		UI_PKEY_GlobalHighlightColor = PROPERTYKEY[VT_UI4, 2001]
		UI_PKEY_GlobalTextColor = PROPERTYKEY[VT_UI4, 2002]

		def UI_GetHValue(hsb) LOBYTE(hsb) end
		def UI_GetSValue(hsb) LOBYTE(hsb >> 8) end
		def UI_GetBValue(hsb) LOBYTE(hsb >> 16) end
		def UI_HSB(h, s, b) h | (s << 8) | (b << 16) end

		def UI_RGB2HSB(r, g, b)
			r, g, b = r.to_f / 255, g.to_f / 255, b.to_f / 255

			max, min = [r, g, b].max, [r, g, b].min

			l = (max + min) / 2

			s = if max == min
				0
			elsif l < 0.5
				(max - min) / (max + min)
			else
				(max - min) / (2 - (max + min))
			end

			h = if max == min
				0
			elsif r == max
				    (g - b) / (max - min)
			elsif g == max
				2 + (b - r) / (max - min)
			else
				4 + (r - g) / (max - min)
			end * 60

			h += 360 if h < 0

			h = h / 360

			[
				# hue
				(255 * h).round,

				# saturation
				(255 * s).round,

				# brightness
				(l < 0.1793) ?
					0 :
					(l > 0.9821) ?
						255 :
						(257.7 + 149.9 * Math.log(l)).round
			]
		end

		module_function \
			:UI_GetHValue, :UI_GetSValue, :UI_GetBValue, :UI_HSB,
			:UI_RGB2HSB

		UI_CONTEXTAVAILABILITY_NOTAVAILABLE = 0
		UI_CONTEXTAVAILABILITY_AVAILABLE = 1
		UI_CONTEXTAVAILABILITY_ACTIVE = 2

		UI_FONTPROPERTIES_NOTAVAILABLE = 0
		UI_FONTPROPERTIES_NOTSET = 1
		UI_FONTPROPERTIES_SET = 2

		UI_FONTVERTICALPOSITION_NOTAVAILABLE = 0
		UI_FONTVERTICALPOSITION_NOTSET = 1
		UI_FONTVERTICALPOSITION_SUPERSCRIPT = 2
		UI_FONTVERTICALPOSITION_SUBSCRIPT = 3

		UI_FONTUNDERLINE_NOTAVAILABLE = 0
		UI_FONTUNDERLINE_NOTSET = 1
		UI_FONTUNDERLINE_SET = 2

		UI_FONTDELTASIZE_GROW = 0
		UI_FONTDELTASIZE_SHRINK = 1

		UI_CONTROLDOCK_TOP = 1
		UI_CONTROLDOCK_BOTTOM = 3

		UI_SWATCHCOLORTYPE_NOCOLOR = 0
		UI_SWATCHCOLORTYPE_AUTOMATIC = 1
		UI_SWATCHCOLORTYPE_RGB = 2

		UI_SWATCHCOLORMODE_NORMAL = 0
		UI_SWATCHCOLORMODE_MONOCHROME = 1

		IUISimplePropertySet = COM::Interface[IUnknown,
			GUID['c205bb48-5b1c-4219-a106-15bd0a5f24e2'],

			GetValue: [[:pointer, :pointer], :long]
		]

		UISimplePropertySet = COM::Instance[IUISimplePropertySet]
		UISimplePropertySetCallback = COM::Callback[IUISimplePropertySet]

		IUIRibbon = COM::Interface[IUnknown,
			GUID['803982ab-370a-4f7e-a9e7-8784036a6e26'],

			GetHeight: [[:pointer], :long],
			LoadSettingsFromStream: [[:pointer], :long],
			SaveSettingsToStream: [[:pointer], :long]
		]

		UIRibbon = COM::Instance[IUIRibbon]

		UI_INVALIDATIONS_STATE = 0x00000001
		UI_INVALIDATIONS_VALUE = 0x00000002
		UI_INVALIDATIONS_PROPERTY = 0x00000004
		UI_INVALIDATIONS_ALLPROPERTIES = 0x00000008

		UI_ALL_COMMANDS = 0

		IUIFramework = COM::Interface[IUnknown,
			GUID['F4F0385D-6872-43a8-AD09-4C339CB3F5C5'],

			Initialize: [[:pointer, :pointer], :long],
			Destroy: [[], :long],
			LoadUI: [[:pointer, :buffer_in], :long],
			GetView: [[:uint, :pointer, :pointer], :long],
			GetUICommandProperty: [[:uint, :pointer, :pointer], :long],
			SetUICommandProperty: [[:uint, :pointer, :pointer], :long],
			InvalidateUICommand: [[:uint, :int, :pointer], :long],
			FlushPendingInvalidations: [[], :long],
			SetModes: [[:int], :long]
		]

		UIFramework = COM::Factory[IUIFramework, GUID['926749fa-2615-4987-8845-c33e65f2b957']]

		IUIContextualUI = COM::Interface[IUnknown,
			GUID['EEA11F37-7C46-437c-8E55-B52122B29293'],

			ShowAtLocation: [[:int, :int], :long]
		]

		UIContextualUI = COM::Instance[IUIContextualUI]

		IUICollection = COM::Interface[IUnknown,
			GUID['DF4F45BF-6F9D-4dd7-9D68-D8F9CD18C4DB'],

			GetCount: [[:pointer], :long],
			GetItem: [[:uint, :pointer], :long],
			Add: [[:pointer], :long],
			Insert: [[:uint, :pointer], :long],
			RemoveAt: [[:uint], :long],
			Replace: [[:uint, :pointer], :long],
			Clear: [[], :long]
		]

		UICollection = COM::Instance[IUICollection]

		class UICollection
			include Enumerable

			def count; FFI::MemoryPointer.new(:uint) { |pc| GetCount(pc); return pc.get_uint(0) } end
			alias :size :count
			alias :length :count

			def get(i) FFI::MemoryPointer.new(:pointer) { |punk| GetItem(i, punk); return Unknown.new(punk.read_pointer) } end
			def add(unknown) Add(unknown); self end
			def clear; Clear(); self end

			def each; length.times { |i| yield get(i) }; self end
		end

		UI_COLLECTIONCHANGE_INSERT = 0
		UI_COLLECTIONCHANGE_REMOVE = 1
		UI_COLLECTIONCHANGE_REPLACE = 2
		UI_COLLECTIONCHANGE_RESET = 3

		UI_COLLECTION_INVALIDINDEX = 0xffffffff

		IUICollectionChangedEvent = COM::Interface[IUnknown,
			GUID['6502AE91-A14D-44b5-BBD0-62AACC581D52'],

			OnChanged: [[:int, :uint, :pointer, :uint, :pointer], :long]
		]

		UICollectionChangedEvent = COM::Callback[IUICollectionChangedEvent]

		UI_EXECUTIONVERB_EXECUTE = 0
		UI_EXECUTIONVERB_PREVIEW = 1
		UI_EXECUTIONVERB_CANCELPREVIEW = 2

		IUICommandHandler = COM::Interface[IUnknown,
			GUID['75ae0a2d-dc03-4c9f-8883-069660d0beb6'],

			Execute: [[:uint, :int, :pointer, :pointer, :pointer], :long],
			UpdateProperty: [[:uint, :pointer, :pointer, :pointer], :long]
		]

		UICommandHandler = COM::Callback[IUICommandHandler]

		UI_COMMANDTYPE_UNKNOWN = 0
		UI_COMMANDTYPE_GROUP = 1
		UI_COMMANDTYPE_ACTION = 2
		UI_COMMANDTYPE_ANCHOR = 3
		UI_COMMANDTYPE_CONTEXT = 4
		UI_COMMANDTYPE_COLLECTION = 5
		UI_COMMANDTYPE_COMMANDCOLLECTION = 6
		UI_COMMANDTYPE_DECIMAL = 7
		UI_COMMANDTYPE_BOOLEAN = 8
		UI_COMMANDTYPE_FONT = 9
		UI_COMMANDTYPE_RECENTITEMS = 10
		UI_COMMANDTYPE_COLORANCHOR = 11
		UI_COMMANDTYPE_COLORCOLLECTION = 12

		UI_VIEWTYPE_RIBBON = 1

		UI_VIEWVERB_CREATE = 0
		UI_VIEWVERB_DESTROY = 1
		UI_VIEWVERB_SIZE = 2
		UI_VIEWVERB_ERROR = 3

		IUIApplication = COM::Interface[IUnknown,
			GUID['D428903C-729A-491d-910D-682A08FF2522'],

			OnViewChanged: [[:uint, :int, :pointer, :int, :int], :long],
			OnCreateUICommand: [[:uint, :int, :pointer], :long],
			OnDestroyUICommand: [[:uint, :int, :pointer], :long]
		]

		UIApplication = COM::Callback[IUIApplication]

		IUIImage = COM::Interface[IUnknown,
			GUID['23c8c838-4de6-436b-ab01-5554bb7c30dd'],

			GetBitmap: [[:pointer], :long]
		]

		UIImage = COM::Instance[IUIImage]

		UI_OWNERSHIP_TRANSFER = 0
		UI_OWNERSHIP_COPY = 1

		IUIImageFromBitmap = COM::Interface[IUnknown,
			GUID['18aba7f3-4c1c-4ba2-bf6c-f5c3326fa816'],

			CreateImage: [[:pointer, :int, :pointer], :long]
		]

		UIImageFromBitmap = COM::Factory[IUIImageFromBitmap, GUID['0f7434b6-59b6-4250-999e-d168d6ae4293']]

		def UI_MAKEAPPMODE(x) 1 << x end

		module_function :UI_MAKEAPPMODE
	end

	class Windows::PropertyStore
		def uiprop(*args)
			args[0] = Windows.const_get("UI_PKEY_#{args[0]}")

			prop(*args)
		end

		def update(from)
			case from
			when Windows::LOGFONT
				uiprop(:FontProperties_Family, Windows::PROPVARIANT[:wstring, from.face])
				uiprop(:FontProperties_Size, Windows::PROPVARIANT[:decimal, from.size.round])
				uiprop(:FontProperties_Bold, Windows::PROPVARIANT[:uint, (from.bold?) ? 2 : 1])
				uiprop(:FontProperties_Italic, Windows::PROPVARIANT[:uint, (from.italic?) ? 2 : 1])
				uiprop(:FontProperties_Underline, Windows::PROPVARIANT[:uint, (from.underline?) ? 2 : 1])
				uiprop(:FontProperties_Strikethrough, Windows::PROPVARIANT[:uint, (from.strikeout?) ? 2 : 1])
			else raise ArgumentError
			end

			self
		end
	end

	class Windows::UISimplePropertySet
		def get(k) Windows::PROPVARIANT.new.tap { |v| GetValue(k, v) } end

		def prop(*args)
			case args.length
			when 1; get(*args)
			else raise ArgumentError
			end
		end

		def uiprop(*args)
			args[0] = Windows.const_get("UI_PKEY_#{args[0]}")

			prop(*args)
		end
	end

	class UIRibbon
		class Command
			include Toggle

			def initialize(ribbon, id)
				@ribbon, @id = ribbon, id
			end

			attr_reader :ribbon, :id

			def [](k) Windows::PROPVARIANT.new.tap { |v| ribbon.uif.GetUICommandProperty(id, k, v) } end
			def []=(k, v) ribbon.uif.SetUICommandProperty(id, k, v) end

			def enabled?; self[Windows::UI_PKEY_Enabled].bool end
			def enabled=(enabled) self[Windows::UI_PKEY_Enabled] = Windows::PROPVARIANT[:bool, enabled] end

			def checked?; self[Windows::UI_PKEY_BooleanValue].bool end
			def checked=(checked) self[Windows::UI_PKEY_BooleanValue] = Windows::PROPVARIANT[:bool, checked] end
		end

		def [](id) Command.new(self, id) end

		module Color
			def self.enhance(hsb, ribbon, method)
				hsb.instance_variable_set(:@ribbon, ribbon)
				hsb.instance_variable_set(:@method, method)

				class << hsb
					attr_reader :ribbon, :method

					include Color
				end

				hsb
			end

			def darken(amount) self[2] -= amount; ribbon.send("#{method}=", self); self end
			def lighten(amount) self[2] += amount; ribbon.send("#{method}=", self); self end

			def saturate(amount) self[1] += amount; ribbon.send("#{method}=", self); self end
			def bleach(amount) self[1] -= amount; ribbon.send("#{method}=", self); self end

			def shift(amount) self[0] += amount; ribbon.send("#{method}=", self); self end
		end

		def background
			hsb = nil

			uif.QueryInstance(Windows::PropertyStore) { |ps|
				hsb = ps.uiprop(:GlobalBackgroundColor).uint
			}

			Color.enhance([Windows::UI_GetHValue(hsb), Windows::UI_GetSValue(hsb), Windows::UI_GetBValue(hsb)], self, __method__)
		end

		def background=(hsb)
			uif.QueryInstance(Windows::PropertyStore) { |ps|
				ps.uiprop(:GlobalBackgroundColor, Windows::PROPVARIANT[:uint, Windows::UI_HSB(*hsb)]).commit
			}
		end

		def color
			hsb = nil

			uif.QueryInstance(Windows::PropertyStore) { |ps|
				hsb = ps.uiprop(:GlobalTextColor).uint
			}

			Color.enhance([Windows::UI_GetHValue(hsb), Windows::UI_GetSValue(hsb), Windows::UI_GetBValue(hsb)], self, __method__)
		end

		def color=(hsb)
			uif.QueryInstance(Windows::PropertyStore) { |ps|
				ps.uiprop(:GlobalTextColor, Windows::PROPVARIANT[:uint, Windows::UI_HSB(*hsb)]).commit
			}
		end

		def highlight
			hsb = nil

			uif.QueryInstance(Windows::PropertyStore) { |ps|
				hsb = ps.uiprop(:GlobalHighlightColor).uint
			}

			Color.enhance([Windows::UI_GetHValue(hsb), Windows::UI_GetSValue(hsb), Windows::UI_GetBValue(hsb)], self, __method__)
		end

		def highlight=(hsb)
			uif.QueryInstance(Windows::PropertyStore) { |ps|
				ps.uiprop(:GlobalHighlightColor, Windows::PROPVARIANT[:uint, Windows::UI_HSB(*hsb)]).commit
			}
		end

		class GalleryItem < Windows::UISimplePropertySetCallback
			def initialize(label, categoryId = 0, image = nil)
				@label, @categoryId, @image = label, categoryId, image

				super()
			end

			attr_reader :label, :categoryId, :image

			def GetValue(pkey, pvalue)
				key, value = Windows::PROPERTYKEY.new(pkey), Windows::PROPVARIANT.new(pvalue)

				case key
				when Windows::UI_PKEY_CategoryId
					value.uint = @categoryId; Windows::S_OK
				when Windows::UI_PKEY_Label
					value.wstring = @label; Windows::S_OK
				when Windows::UI_PKEY_ItemImage
					FFI::MemoryPointer.new(:pointer) { |punk|
						Windows::UIImageFromBitmap.new.CreateImage(PARGB32.new(@image).handle, Windows::UI_OWNERSHIP_TRANSFER, punk)

						unk = Windows::Unknown.new(punk.read_pointer)
						value.unknown = unk
						unk.Release
					}

					Windows::S_OK
				else
					Windows::E_NOTIMPL
				end
			end
		end

		def initialize(_window, opts = {})
			handlers = {}

			opts.delete_if { |k, v|
				next false unless v.kind_of?(Proc)

				handlers[k] = v; true
			}

			_opts = {
				name: Application.name,
				resname: 'APPLICATION_RIBBON'
			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			@creates = []
			@destroys = []
			@sizes = []
			@executesAllVerbs = {}
			@executesExecute = {}
			@executesPreview = {}
			@executesCancelPreview = {}
			@updatesAllKeys = {}

			@window = _window

			window.instance_variable_set(:@ribbon, self)

			class << window
				attr_reader :ribbon
			end

			@uich = Windows::UICommandHandler.new

			uich.instance_variable_set(:@ribbon, self)

			class << uich
				attr_reader :ribbon

				def Execute(*args) ribbon.execute(*args); Windows::S_OK end
				def UpdateProperty(*args) ribbon.update(*args); Windows::S_OK end
			end

			@uia = Windows::UIApplication.new

			uia.instance_variable_set(:@uich, @uich)

			class << uia
				attr_reader :uich, :uir

				def OnViewChanged(viewId, typeId, view, verb, reason)
					return Windows::S_OK unless typeId == Windows::UI_VIEWTYPE_RIBBON

					args = {
						viewId: viewId,
						typeId: typeId,
						view: view,
						verb: verb,
						reason: reason,
						ribbon: self,
						sender: self
					}

					case verb
					when Windows::UI_VIEWVERB_CREATE
						@uir = Windows::Unknown.new(view).QueryInstance(Windows::UIRibbon)

						uir.instance_variable_set(:@height, 0)

						class << uir
							attr_accessor :height
						end

						uich.ribbon.instance_variable_get(:@creates).each { |handler|
							(handler.arity == 0) ? handler.call : handler.call(args)
						}
					when Windows::UI_VIEWVERB_DESTROY
						uich.ribbon.instance_variable_get(:@destroys).each { |handler|
							(handler.arity == 0) ? handler.call : handler.call(args)
						}

						uir.Release
					when Windows::UI_VIEWVERB_SIZE
						FFI::MemoryPointer.new(:uint) { |p| uir.GetHeight(p); uir.height = p.read_int }

						uich.ribbon.instance_variable_get(:@sizes).each { |handler|
							(handler.arity == 0) ? handler.call : handler.call(args)
						}
					end

					Windows::S_OK
				rescue
					Fzeet.message %Q{#{$!}\n\n#{$!.backtrace.join("\n")}}, icon: :error

					Windows::S_OK
				end

				def OnCreateUICommand(*args) uich.QueryInterface(uich.class::IID, args[-1]); Windows::S_OK end
			end

			@hdll = Windows.LoadRibbonDll(_opts[:name])

			handlers.each { |k, v|
				k[1] = Object.const_get(k[1]) if k.length > 1

				on(*k, &v)
			}

			@uif = Windows::UIFramework.new

			uif.Initialize(window.handle, uia)
			uif.LoadUI(@hdll, "#{_opts[:resname]}\0".encode('utf-16le'))

			window.on(:destroy) {
				raise unless uif.Destroy == Windows::S_OK; raise unless uif.Release == 0
				raise unless uia.Release == 0
				raise unless uich.Release == 0
			}
		end

		attr_reader :hdll, :window, :uich, :uia, :uif

		def height; uia.uir.height end

		def execute(commandId, verb, key, value, props)
			args = {
				commandId: commandId,
				verb: verb,
				key: (key.null?) ? nil : Windows::PROPERTYKEY.new(key),
				value: (value.null?) ? nil : Windows::PROPVARIANT.new(value),
				props: (props.null?) ? nil : Windows::UISimplePropertySet.new(props),
				ribbon: self,
				sender: Command.new(self, commandId)
			}

			(handlers = @executesAllVerbs[commandId]) and handlers.each { |handler|
				(handler.arity == 0) ? handler.call : handler.call(args)
			}

			case verb
			when Windows::UI_EXECUTIONVERB_EXECUTE
				(handlers = @executesExecute[commandId]) and handlers.each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)
				}
			when Windows::UI_EXECUTIONVERB_PREVIEW
				(handlers = @executesPreview[commandId]) and handlers.each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)
				}
			when Windows::UI_EXECUTIONVERB_CANCELPREVIEW
				(handlers = @executesCancelPreview[commandId]) and handlers.each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)
				}
			end

			self
		rescue
			Fzeet.message %Q{#{$!}\n\n#{$!.backtrace.join("\n")}}, icon: :error

			self
		end

		def update(commandId, key, value, newValue)
			args = {
				commandId: commandId,
				key: (key.null?) ? nil : Windows::PROPERTYKEY.new(key),
				value: (value.null?) ? nil : Windows::PROPVARIANT.new(value),
				newValue: (newValue.null?) ? nil : Windows::PROPVARIANT.new(newValue),
				ribbon: self,
				sender: Command.new(self, commandId)
			}

			(handlers = @updatesAllKeys[commandId]) and handlers.each { |handler|
				(handler.arity == 0) ? handler.call : handler.call(args)
			}

			self
		rescue
			Fzeet.message %Q{#{$!}\n\n#{$!.backtrace.join("\n")}}, icon: :error

			self
		end

		def invalidate(commandId, flags = Windows::UI_INVALIDATIONS_ALLPROPERTIES, key = nil)
			@uif.InvalidateUICommand(commandId, flags, key)

			self
		end

		def on(*args, &block)
			case args.size
			when 1
				case args[0]
				when /^create$/i; @creates << block
				when /^destroy$/i; @destroys << block
				when /^size$/i; @sizes << block
				when Integer; (@executesAllVerbs[args[0]] ||= []) << block
				else raise ArgumentError
				end
			when 2
				case args[0]
				when /^execute$/i; (@executesExecute[args[1]] ||= []) << block
				when /^preview$/i; (@executesPreview[args[1]] ||= []) << block
				when /^cancelpreview$/i; (@executesCancelPreview[args[1]] ||= []) << block
				when /^update$/i; (@updatesAllKeys[args[1]] ||= []) << block
				else raise ArgumentError
				end
			else raise ArgumentError
			end

			self
		end

		def fontPropsUpdate(args)
			return self unless args[:key] == Windows::UI_PKEY_FontProperties

			args[:value].unknown { |current|
				current.QueryInstance(Windows::PropertyStore) { |ps|
					yield ps

					args[:newValue].unknown = current
				}
			}

			self
		end

		def fontPropsChanged(args)
			return self unless args[:key] == Windows::UI_PKEY_FontProperties

			args[:props].uiprop(:FontProperties_ChangedProperties).unknown { |changed|
				changed.QueryInstance(Windows::PropertyStore) { |ps|
					yield ps
				}
			}

			self
		end

		def contextualUI(id, x, y)
			uif.UseInstance(Windows::UIContextualUI, :GetView, id) { |view|
				view.ShowAtLocation(x, y)
			}

			self
		end
	end
end
