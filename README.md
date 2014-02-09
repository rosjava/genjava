genjava
=======

RosJava message definition and serialization artifact generators.

For future reference, executing the generator from the command line requires a command of the following kind:

```
java -classpath .:./message_generation-0.1.16.jar org.ros.internal.message.GenerateInterfaces
```

This doesn't work exactly though because it doesn't pull in the full classpath. Make sure that is set to include everything you need. You'll also need arguments of the kind we're currently using in the hydro groovy plugin:

```
        def generatedSourcesDir = "${p.buildDir}/generated-src"
        def generateSourcesTask = p.tasks.create("generateSources", JavaExec)
        generateSourcesTask.description = "Generate sources for " + pkg.name
        generateSourcesTask.outputs.dir(p.file(generatedSourcesDir))
        /* generateSourcesTask.args = new ArrayList<String>([generatedSourcesDir, pkg.name]) */
        generateSourcesTask.args = new ArrayList<String>([generatedSourcesDir, '--package-path=' + pkg.directory, pkg.name])
        generateSourcesTask.classpath = p.configurations.runtime
        generateSourcesTask.main = 'org.ros.internal.message.GenerateInterfaces'
        p.tasks.compileJava.source generateSourcesTask.outputs.files
```

