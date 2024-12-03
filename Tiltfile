def dotnet(day):
    folder = "day{}".format(day)
    local_resource(
        "{}:both".format(folder),
        serve_cmd=["dotnet", "watch", "run", "--", "1", "input.txt"],
        serve_dir=folder,
        auto_init=False,
        trigger_mode=TRIGGER_MODE_MANUAL,
        labels=[folder]
    )

dotnet(1)