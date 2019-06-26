<?php
declare(strict_types=1);

use App\Transducers;
use App\Utils;

require "vendor/autoload.php";

/**
 * @param $value
 * @param string $msg
 */
function echom($value, string $msg = "") {
    if ($msg !== "") {
        echo "$msg: ";
    }
    echo json_encode($value);
    echo "\n";
}

$a = [];
for ($i = 0; $i < 10e6; $i++) {
    $a[] = $i;
}

$inc = function($x) {
    sleep(1 );
    return $x * 10;
};

$gt2 = function($x) {
    return $x > 2;
};

// performs all transformations on the first element of the collection before moving on to the second
$transducedFilterAndMap = Utils::compose(
    Transducers::map($inc),
    Transducers::filter($gt2)
//
//    Transducers::filter($gt2),
//    Transducers::map($inc)
);

Utils::timeAndLogFunction(
    function() use ($transducedFilterAndMap, $a) {
        echom(Utils::arrayTransduce($transducedFilterAndMap, $a));
    },
    "transducedFilterAndMap"
);

Utils::timeAndLogFunction(
    function() use ($a, $gt2, $inc) {
        echom(
            array_values(array_map($inc, array_filter($a, $gt2)))
//            array_filter(array_map($inc, $a), $gt2)
        );
    },
    "normalFilterAndMap"
);


exit;