<?php
declare(strict_types=1);


namespace App\Monad\Either;

/**
 * Represents errors
 * @package App\Monad\Either
 */
class Left extends Either
{
    protected $data;
    
    public function __construct($data) {
        
        $this->data = $data;
    }
    
    /**
     * @return mixed
     */
    public function getData()
    {
        return $this->data;
    }
}