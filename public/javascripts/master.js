$(function() {
  $(".buy a").click(function(e) {
    e.preventDefault();
    $("#buy").show();
  });

  $("#q-more").click(function(e) {
    productIncrement();
    e.preventDefault();
  });

  $("#q-less").click(function(e) {
    productDecrement();
    e.preventDefault();
  });

  $("#quantity").keydown(function(event) {
    var inputNode = $(this);
    var currentValue = parseInt(inputNode.val());

    if (event.keyCode == 38) {
      return productIncrement();
    }
    else if (event.keyCode == 40 && currentValue > 1) {
      return productDecrement();
    }
  });

  function productIncrement() {
    inputNode = $("#quantity");
    if (typeof(parseInt(inputNode.val())) === typeof(1) &&
      !isNaN(parseInt(inputNode.val()))) {
        inputNode.val(parseInt(inputNode.val()) + 1);
    }
    else {
      inputNode.val("1");
    }
    updateAmount(inputNode.val());
  }

  function productDecrement() {
    inputNode = $("#quantity")
    if (parseInt(inputNode.val()) > 1) {
      inputNode.val(parseInt(inputNode.val()) - 1);
    }
    else if (! parseInt(inputNode.val())) {
      inputNode.val(1);
    }
    updateAmount(inputNode.val());
  }

  function updateAmount(quantity) {
    amount = quantity * 7.00;
    discount = amount * 0.10;
    total = amount - discount;

    $("#amount span").replaceWith("<span>" + total + "</span>");
  }
});
