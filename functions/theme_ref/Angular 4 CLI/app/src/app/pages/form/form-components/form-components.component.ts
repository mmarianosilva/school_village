import { Component, OnInit } from '@angular/core';
import { Select2OptionData } from 'ng2-select2';

@Component({
  selector: 'app-form-components',
  templateUrl: './form-components.component.html',
  styleUrls: ['./form-components.component.scss']
})
export class FormComponentsComponent implements OnInit {

  // Input Masking
  maskDate: any = [/[1-9]/, /\d/, '/', /\d/, /\d/, '/', /\d/, /\d/, /\d/, /\d/];
  maskTime: any = [/[1-9]/, /\d/, ':', /\d/, /\d/, ':', /\d/, /\d/];
  maskDateTime: any = [/[1-9]/, /\d/, '/', /\d/, /\d/, '/', /\d/, /\d/, /\d/, /\d/, ' ', /\d/, /\d/, ':', /\d/, /\d/, ':', /\d/, /\d/];
  maskCEP: any = [/[1-9]/, /\d/, /\d/, /\d/, /\d/, '-', /\d/, /\d/,/\d/];
  maskCPF: any = [/[1-9]/, /\d/, /\d/, '.', /\d/, /\d/,/\d/, /\d/, /\d/,/\d/, '-', /\d/, /\d/];
  maskCreditCard: any = [/[1-9]/, /\d/, /\d/, /\d/, ' ', /\d/, /\d/, /\d/, /\d/, ' ', /\d/, /\d/, /\d/, /\d/, ' ', /\d/, /\d/, /\d/, /\d/, ' '];
  maskPhone: any = [/[1-9]/, /\d/, /\d/, '-', /\d/, /\d/, '-', /\d/, /\d/, /\d/, /\d/, /\d/, /\d/, /\d/];
  maskPhoneOdd: any = ['(', /[1-9]/, /\d/,')', ' ', /\d/, /\d/, /\d/, /\d/, '-', /\d/, /\d/, /\d/, /\d/];
  maskPhoneUS: any = ['(', /[1-9]/, /\d/, /\d/,')', ' ', /\d/, /\d/, /\d/, '-', /\d/, /\d/, /\d/, /\d/];
  maskMoney: any = ['$', /[1-9]/, /\d/, /\d/, '.', /\d/, /\d/, /\d/, '.', /\d/, /\d/, /\d/, '.', /\d/, /\d/, /\d/, '.', /\d/, /\d/, /\d/, ',', /\d/, /\d/];
  maskIP: any = [/[1-9]/, /\d/, /\d/, '.', /\d/, /\d/, /\d/, '.', /\d/, /\d/, /\d/, '.', /\d/, /\d/, /\d/];
  maskPercentage: any = [/[1-9]/, /\d/, '.', /\d/, /\d/, '%'];


  // Select2 (ng2-select2)
  select2Data: Array<Select2OptionData> = [
    { id: '1', text: 'Hyundai' },
    { id: '2', text: 'Kia' },
    { id: '3', text: 'Nissan'},
    { id: '4', text: 'Subaru' },
    { id: '5', text: 'Scion' },
    { id: '6', text: 'Subaru' },
    { id: '7', text: 'Mazda' },
    { id: '8', text: 'Honda' },
    { id: '9', text: 'Mitsubishi' },
    { id: '10', text: 'Suzuki' }
  ];

  select2DataPlaceholder: Array<Select2OptionData> = [
    { id: '', text: '' },
    { id: '2', text: 'Kia' },
    { id: '3', text: 'Nissan'},
    { id: '4', text: 'Subaru' },
    { id: '5', text: 'Scion' },
    { id: '6', text: 'Subaru' },
    { id: '7', text: 'Mazda' },
    { id: '8', text: 'Honda' },
    { id: '9', text: 'Mitsubishi' },
    { id: '10', text: 'Suzuki' }
  ];

  select2DataDisabled: Array<Select2OptionData> = [
    { id: '1', text: 'Hyundai', disabled: true },
    { id: '2', text: 'Kia' },
    { id: '3', text: 'Nissan', disabled: true},
    { id: '4', text: 'Subaru', disabled: true },
    { id: '5', text: 'Scion' },
    { id: '6', text: 'Subaru' },
    { id: '7', text: 'Mazda', disabled: true },
    { id: '8', text: 'Honda' },
    { id: '9', text: 'Mitsubishi', disabled: true },
    { id: '10', text: 'Suzuki' }
  ];

  options: any = {
    dropdownAutoWidth: true,
    width: '100%',
    containerCssClass: 'select2-selection--alt',
    dropdownCssClass: 'select2-dropdown--alt'
  };

  multipleOptions: any = {
    multiple: true,
    dropdownAutoWidth: true,
    placeholder: 'Select one or more items',
    width: '100%',
    containerCssClass: 'select2-selection--alt',
    dropdownCssClass: 'select2-dropdown--alt'
  };

  placeholderOptions: any = {
    placeholder: 'Select an Option',
    dropdownAutoWidth: true,
    width: '100%',
    allowClear: true,
    containerCssClass: 'select2-selection--alt',
    dropdownCssClass: 'select2-dropdown--alt'
  };

  disableSearchOptions: any = {
    dropdownAutoWidth: true,
    minimumResultsForSearch: true,
    width: '100%',
    containerCssClass: 'select2-selection--alt',
    dropdownCssClass: 'select2-dropdown--alt'
  };


  // Dropzone
  dropzonePostUrl:any = 'dropzonePostUrl'


  // Date Picker
  datePickerValue: Date = new Date();
  datePickerMeridianValue: Date = new Date();

  getDate(): number {
    return this.datePickerValue && this.datePickerValue.getTime() || new Date().getTime()
  }

  // Input slider
  inputSliderSingleValue: number = 0;
  inputSliderRangeValue: number[] = [5, 15];

  constructor() { }
  ngOnInit() {}
}
