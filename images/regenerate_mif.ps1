foreach ($file in ls) {
	if ($file.name -match ".png") {
		echo "WORKING ON FILE $($file.name)";
		iex "py -3 ImageParser.py $($file.name) $($file.name.Replace('.png', '.mif'))";
	}
}
