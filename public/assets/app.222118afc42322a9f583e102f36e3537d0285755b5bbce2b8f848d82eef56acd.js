(function() {
    Array.from(document.getElementsByTagName("input")).
        forEach(function(element) {
            element.onchange = function() {
                element.parentNode.classList.toggle("done");
                element.parentNode.classList.toggle("todo");
            }
        });
})();

(function() {
    Array.from(document.getElementsByTagName("input")).
        forEach(function(element) {
            element.onchange = function() {
                element.parentNode.classList.toggle("done");
                element.parentNode.classList.toggle("todo");
            }
        });
})();
