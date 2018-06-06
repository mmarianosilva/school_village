import { Directive, ElementRef, Renderer } from "@angular/core";


@Directive ({
    selector: '[formControlFloat]',
    host: {
        '(blur)': 'onBlur()'
    }
})

export class InputFloatDirective {
    constructor (private el: ElementRef, private renderer: Renderer) { }
    elem:any = this.el.nativeElement;

    onBlur() {
        let status = true ? this.elem.value : false;
        this.renderer.setElementClass(this.elem, 'form-control--active', status)
    }

    ngOnInit() {
        if(this.elem.value) {
            this.renderer.setElementClass(this.elem, 'form-control--active', true)
        }
    }
}