// window.addEventListener('load', () => {
//   const codeListContainer = document.querySelector('.manual-code-entry-code-list')
//   const codeEntryField = document.querySelector('.manual-code-entry__field')
//   const addCodeButton = document.querySelector('.add-new-code__button')
//   const bagCount = document.querySelector('.bags-entered-count')
//   const hiddenField = document.querySelector('#bag_codes')

//   // let codeItem = `
//   // <div class="manual-code__item">
//   //   <button class="remove-code__button">-</button>
//   //   <p class="manual__code">asdf</p>
//   // </div>
//   // `

//   addCodeButton.addEventListener('click', () => {
//     if (codeEntryField.value.length > 0) {
//       let code = `LB-${codeEntryField.value.toUpperCase()}`

//       createCodeElement(code);
//       updateCodesFormField();
//       updateBagCount();
//       codeEntryField.value = "";
//     }
//   })

//   function createCodeElement(code) {
//     let container = document.createElement('div')
//     container.classList.add('manual-code__item')
//     let removeButton = document.createElement('button')
//     removeButton.classList.add('remove-code__button')
//     removeButton.innerText = "-"
//     container.append(removeButton);
//     let codeText = document.createElement('p');
//     container.append(codeText);
//     codeText.classList.add('manual__code');
//     codeText.innerText = code;
//     codeListContainer.append(container);

//     removeButton.addEventListener('click', () => {
//       container.remove();
//       updateBagCount();
//       updateCodesFormField();
//     })
//   }

//   function updateCodesFormField() {
//     let codes = document.querySelectorAll('.manual__code')
//     let storedCodes = []
//     codes.forEach(code => {
//       storedCodes.push(code.innerText)
//     })
//     hiddenField.value = storedCodes.sort().join(', ')
//   }

//   function updateBagCount() {
//     let codes = document.querySelectorAll('.manual-code__item')
//     bagCount.innerText = codes.length
//   }

// })
