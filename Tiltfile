def dotnet(day):
    folder = "day{}".format(day)
    local_resource(
        "{}:both".format(folder),
        serve_cmd=["dotnet", "watch", "run", "--", "input.txt"],
        serve_dir=folder,
        auto_init=False,
        deps=[folder + "/input.txt"],
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

def ihatemyself(day):
    folder = "day{}".format(day)
    local_resource(
        "{}:both".format(folder),
        cmd=["python3", "main.py"],
        dir=folder,
        auto_init=False,
        labels=[folder],
        deps=[folder + "/main.py", folder + "/input.txt"],
    )

dotnet(1)
dlang(2)
golang(3)
dotnet(4)
maven(5)
make(6)
ihatemyself(7)
make(8)
dlang(9)
golang(10)
dotnet(11)