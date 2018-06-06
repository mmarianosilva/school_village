import {Component, OnInit} from '@angular/core';

@Component({
    selector: 'app-sortable',
    templateUrl: './sortable.component.html',
    styleUrls: ['./sortable.component.scss']
})
export class SortableComponent implements OnInit {
    sortableData: any[] = [
        'Morbi leo risus, porta ac consectetur ac, vestibulum at eros.',
        'Sed posuere consectetur est at lobortis.',
        'Nullam quis risus eget urna mollis ornare vel eu leo.',
        'Integer posuere erat a ante venenatis dapibus posuere velit aliquet.',
        'Posuere id dolor id nibh ultricies vehicula ut id elit.',
        'Aenean lacinia bibendum nulla sed consectetur.',
        'Etiam porta sem malesuada magna mollis euismod.',
        'Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.',
        'Praesent commodo cursus magna, vel scelerisque nisl consectetur et.',
        'Sed posuere consectetur est at lobortis.'
    ];

    sortableComplexData: any[] = [
        { id: 1, name: 'Etiam porta sem malesuada magna mollis euismod.' },
        { id: 2, name: 'Praesent commodo cursus magna, vel scelerisque nisl consectetur et.' },
        { id: 3, name: 'Posuere id dolor id nibh ultricies vehicula ut id elit.' },
        { id: 4, name: 'Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.' },
        { id: 5, name: 'Morbi leo risus, porta ac consectetur ac, vestibulum at eros.' },
        { id: 6, name: 'Sed posuere consectetur est at lobortis.' },
    ];

    constructor() {
    }

    ngOnInit() {
    }
}
