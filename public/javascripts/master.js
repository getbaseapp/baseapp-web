$(function() {
  $(".buy a").click(function(e) {
    e.preventDefault();
    $("#buy").show();
  });

  $("#q-more").click(function(e) {
    e.preventDefault();
    $(this).trigger("increment");
  });

  $("#q-less").click(function(e) {
    e.preventDefault();
    $(this).trigger("decrement");
  });

  var quantityInput = $("#quantity")
    .extend({
      quantity: function() {
        return parseInt(quantityInput.val()) || 0
      }
    })

    .keypress(function(e) {
      window.setTimeout(function() { quantityInput.change(); }, 10);
    })

    .change(function(e) {
      var amount   = quantityInput.quantity() * 7.0,
          discount = (quantityInput.quantity() - 1) * 7.0 * 0.1;
          total    = amount - discount;

      $("#amount span").replaceWith("<span>" + total + "</span>");
    });

  $("#paypal")
    .bind('increment', function(e) {
      quantityInput
        .val(quantityInput.quantity() + 1)
        .change();
    })

    .bind('decrement', function(e) {
      quantityInput
        .val(Math.max(1, quantityInput.quantity() - 1))
        .change();
    });

});
