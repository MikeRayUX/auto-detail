const form = document.querySelector('.form');
const select_all_btn = document.querySelector('input[name=select_all]');
const items = document.querySelectorAll('.item');
const delete_selected_btn = document.querySelector('#delete_selected_btn');

delete_selected_btn.addEventListener('click', () => {
  if (window.confirm('are you sure?')) {
    form.submit();
  }
});

select_all_btn.addEventListener('change', ({ target }) => {
  if (target.checked) {
    items.forEach((item) => {
      item.checked = true;
    });
  } else {
    items.forEach((item) => {
      item.checked = false;
    });
  }
  updateToDeleteCount();
});

const updateToDeleteCount = () => {
  let delete_count = 0;

  items.forEach((item) => {
    if (item.checked) {
      delete_count += 1;
    }
  });

  if (delete_count > 0) {
    delete_selected_btn.innerText = `Delete ${delete_count}`;
  } else {
    delete_selected_btn.innerText = 'Delete All';
  }
  console.log('delete_count:', delete_count);
};

if (items && items.length) {
  items.forEach((item) => {
    item.addEventListener('change', ({ target }) => {
      if (target.checked) {
        // console.log('single item checked');
        target.checked = true;
      } else {
        // console.log('single item unchecked');
        target.checked = false;
      }
      updateToDeleteCount();
    });
  });
}
