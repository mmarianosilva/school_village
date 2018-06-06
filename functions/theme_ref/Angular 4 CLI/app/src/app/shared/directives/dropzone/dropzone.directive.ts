/// <reference types="dropzone/"/>
import { Directive, Input, ElementRef } from '@angular/core';
declare var jQuery: any;

@Directive ({
    selector: '[dropzone]'
})

export class DropzoneDirective {
    @Input() private posturl:any;

    constructor(private el: ElementRef) {}

    ngOnInit() {
        let initDropzone = jQuery(this.el.nativeElement)

        initDropzone.dropzone({
            url: this.posturl,
            addRemoveLinks: true
        });
    }
}