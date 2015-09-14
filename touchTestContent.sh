#!/bin/bash
t() {
    echo touching $1
    touch $1
    sleep 2
}
t images/c.png
t images/b.png
t images/a.png
