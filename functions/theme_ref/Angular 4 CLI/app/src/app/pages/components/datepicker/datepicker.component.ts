import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-datepicker',
  templateUrl: './datepicker.component.html',
  styleUrls: ['./datepicker.component.scss']
})
export class DatepickerComponent implements OnInit {
  datePickerValue: Date = new Date();
  datePickerToggle: any = {
    1: false,
    2: false
  }

  toggleDatePicker(datePicker) {
    this.datePickerToggle[datePicker] = !this.datePickerToggle[datePicker]
  }

  getDate(): number {
    return this.datePickerValue && this.datePickerValue.getTime() || new Date().getTime()
  }

  constructor() { }

  ngOnInit() {
  }

}
