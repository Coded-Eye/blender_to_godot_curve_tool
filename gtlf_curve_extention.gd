class_name GLTFCurveExtention
extends GLTFDocumentExtension

func _import_preflight(state: GLTFState, extensions: PackedStringArray) -> Error:
	if extensions.has("UTSUBO_curve_extension") == false:
		return Error.FAILED
	return Error.OK


func _parse_node_extensions(state: GLTFState, gltf_node: GLTFNode, extensions: Dictionary) -> Error:
	var data : Dictionary = extensions["UTSUBO_curve_extension"]
	if data.has("splines") == false:
		return Error.FAILED

	var curves :  Array[Curve3D] = []

	var splines : Array = data["splines"]

	for spline in splines:
		var spline_type : String = spline.get("type")
		var points : Array = spline.get("points")
		var closed : bool = spline.get("use_cyclic_u")
		match spline_type:
			"BEZIER":
				var new_curve := Curve3D.new()
				for idx in range(points.size()):
					new_curve.add_point(
						Vector3(points[idx]["co"][0], points[idx]["co"][2], -points[idx]["co"][1]),
						Vector3(points[idx]["handle_left"][0] - points[idx]["co"][0], points[idx]["handle_left"][2] - points[idx]["co"][2],-points[idx]["handle_left"][1] - -points[idx]["co"][1]),
						Vector3(points[idx]["handle_right"][0] - points[idx]["co"][0], points[idx]["handle_right"][2] - points[idx]["co"][2],-points[idx]["handle_right"][1] - -points[idx]["co"][1]),
					)
					new_curve.set_point_tilt(idx, points[idx]["tilt"])
				new_curve.closed = closed
				curves.append(new_curve)

			"NURBS":
				var new_curve := Curve3D.new()
				for idx in range(points.size()):
					new_curve.add_point(
						Vector3(points[idx]["co"][0], points[idx]["co"][2], -points[idx]["co"][1]),
					)
					new_curve.set_point_tilt(idx, points[idx]["tilt"])
				new_curve.closed = closed
				curves.append(new_curve)
			"POLY":
				var new_curve := Curve3D.new()
				for idx in range(points.size()):
					new_curve.add_point(
						Vector3(points[idx]["co"][0], points[idx]["co"][2], -points[idx]["co"][1]),
					)
				new_curve.closed = closed
				curves.append(new_curve)



	gltf_node.set_additional_data("GLTFCurveExtention", curves)

	return OK

func _generate_scene_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node) -> Node3D:
	if gltf_node.get_additional_data("GLTFCurveExtention") != null:
		var curves : Array[Curve3D] = gltf_node.get_additional_data("GLTFCurveExtention")
		var node3d := Node3D.new()

		for idx in range(curves.size()):
			var path3d := Path3D.new()
			path3d.curve = curves[idx]
			node3d.add_child(path3d)

		return node3d

	return

func _import_post(_state: GLTFState, _root: Node) -> Error:
	print("gLTF Import done")
	return OK
