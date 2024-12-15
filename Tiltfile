def dotnet(day):
    folder = "day{}".format(day)
    local_resource(
        "{}:both".format(folder),
        serve_cmd=["dotnet", "watch", "run", "--", "input.txt"],
        serve_dir=folder,
        auto_init=False,
        labels=[folder]
    )

def dlang(day):
    folder = "day{}".format(day)
    local_resource(
        "{}:both".format(folder),
        cmd=["dub", "run", "--", "input.txt"],
        dir=folder,
        auto_init=False,
        labels=[folder],
        deps=[folder + "/source/", folder + "/input.txt"]
    )

def golang(day):
    folder = "day{}".format(day)
    local_resource(
        "{}:both".format(folder),
        cmd=["go", "run", "./", "input.txt"],
        dir=folder,
        auto_init=False,
        labels=[folder],
        deps=[folder + "/main.go", folder + "/input.txt"]
    )

def maven(day):
    folder = "day{}".format(day)
    local_resource(
        "{}:both".format(folder),
        cmd=["mvn", "exec:java"],
        dir=folder,
        auto_init=False,
        labels=[folder],
        deps=[folder + "/src/", folder + "/input.txt"],
    )

def make(day):
    folder = "day{}".format(day)
    local_resource(
        "{}:both".format(folder),
        cmd=["make", "run"],
        dir=folder,
        auto_init=False,
        labels=[folder],
        deps=[folder + "/src/", folder + "/input.txt"],
    )
dotnet(1)
dlang(2)
golang(3)
dotnet(4)
maven(5)
make(6)