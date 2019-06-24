<?php
declare(strict_types=1);


namespace Tests;

trait LambdasAsMethods
{
    public function __call($name, $args)
    {
        return call_user_func_array($this->$name, $args);
    }
}
