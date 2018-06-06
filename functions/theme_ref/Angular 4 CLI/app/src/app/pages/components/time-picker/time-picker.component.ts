import {Component, OnInit} from '@angular/core';

@Component({
    selector: 'app-time-picker',
    templateUrl: './time-picker.component.html',
    styleUrls: ['./time-picker.component.scss']
})
export class TimePickerComponent implements OnInit {
    isTimePickerEnabled: boolean = true;
    timePickerValue: Date = new Date();
    timePickerMeridianValue: Date = new Date();

    constructor() {
    }

    ngOnInit() {
    }

}
