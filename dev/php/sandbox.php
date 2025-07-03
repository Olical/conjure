<?php

$fn = fn(int $x) => $x * $x;

$fn(5);

class Adder
{
    public function __construct(
        private int $base
    ) {}

    public function add(int $add): int
    {
        return $this->base + $add;
    }
}

$test = new Adder(100);

$test->add(12);
