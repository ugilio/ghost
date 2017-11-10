package it.cnr.istc.ghost.standalonecompiler;

import java.util.Collections;
import java.util.List;

import com.google.devtools.common.options.Option;
import com.google.devtools.common.options.OptionsBase;

public class GhostCOptions extends OptionsBase {
	@Option(
		name = "help",
		abbrev = 'h',
		help = "Prints this help",
		defaultValue = "false"
	)
	public boolean help;

	@Option(
		name = "version",
		abbrev = 'v',
		help = "Shows the program version",
		defaultValue = "false"
	)
	public boolean version;

	@Option(
		name = "path",
		abbrev = 'P',
		help = "Adds the specified directory to the search path for imported domains",
		allowMultiple = true,
		defaultValue = ""
	)
	public List<String> searchPaths;
	
	public List<String> fnames = Collections.emptyList();

}
