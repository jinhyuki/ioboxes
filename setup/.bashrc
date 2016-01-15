function ioboxes {
    if [ "$1" = "hello" ] then
        echo "hello!"
    elif [ "$1" = "upgrade" ] then
        echo "upgrade!"
    fi
}