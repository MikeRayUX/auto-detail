const clipboard = new ClipboardJS('.copy-address-button');

clipboard.on('success', function (e) {
  alert('Address copied!');

  e.clearSelection();
});

clipboard.on('error', function (e) {
  alert('Error: Address not copied.');
});
