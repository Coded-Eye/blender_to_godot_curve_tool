@tool
extends EditorPlugin

var curve_extention := GLTFCurveExtention.new()

func _enter_tree() -> void:
	GLTFDocument.register_gltf_document_extension(curve_extention)


func _exit_tree() -> void:
	GLTFDocument.unregister_gltf_document_extension(curve_extention)
