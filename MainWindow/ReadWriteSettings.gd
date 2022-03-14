extends Node

var current_settings: Dictionary;

func _ready():
	current_settings = read_settings_file()

func read_settings_file() -> Dictionary:
	var settings_file: File = File.new()
	if settings_file.open(ProjectSettings.get_setting("global/conf_filename"), File.READ):
		print_debug("Cannot read file")
		return {}
	
	var jsonResult: JSONParseResult = JSON.parse(settings_file.get_as_text())
	settings_file.close()
	if(jsonResult.error):
		print_debug("Cannot parse file")
		return {}
	
	return jsonResult.result

func write_settings_file():
	var settings_file: File = File.new()
	if(settings_file.open(ProjectSettings.get_setting("global/conf_filename"), File.WRITE)):
		print_debug("Cannot find file")
	settings_file.store_string(JSON.print(current_settings, "\t"))
	settings_file.flush()
	settings_file.close()
