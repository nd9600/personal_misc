<?php
declare(strict_types=1);


namespace App\Monad\Either;

/**
 * Represents success
 * @package App\Monad\Either
 */
class Right extends Either
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