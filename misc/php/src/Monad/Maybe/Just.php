<?php
declare(strict_types=1);


namespace App\Monad\Maybe;


class Just extends Maybe
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