
var chemrpsserviceurlprefix;

var sdfilefieldnamessource;

var uploadedfilename;

var numberofsdfilerecords;

var registrationmessages = "";

function isNotEmpty(value) {



    if (typeof value !== 'undefined') {



        if (value !== null) {


            if (value) {



                return true;


            } else {




                return false;


            }



        } else {


            return false;


        }






    } else { return false; }



}

function ValidateSDFile(fileName, compoundname) {

    $("#jqxLoader").jqxLoader({ isModal: true, width: 100, height: 60, imagePosition: 'top', text: 'Validate SDFile' });

    $('#jqxLoader').jqxLoader('open');

    $.ajax({

        async: true,

        type: "GET",




        url: chemrpsserviceurlprefix + "ValidateSDFile/" + fileName + "/" + compoundname,



        cache: false,






        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {


            $('#jqxLoader').jqxLoader('close');

           


            if (response.bError) {


                alert(response.errortext);


            } else {

                $('#chartContainervalidationresults').show();

                var settings = {
                    title: "Validation result",
                    description: "",
                    showLegend: false,
                    showToolTips: false,
                    enableAnimations: true,
                    padding: { left: 20, top: 5, right: 20, bottom: 5 },
                    titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
                    borderLineWidth: 0,
                    source: response.items,
                    xAxis:
                    {

                        dataField: 'context',
                        gridLines: { visible: false },
                        flip: false,


                    },

                    valueAxis:
                    {
                        visible: false,
                        
                        minValue: 0,
                        maxValue: response.numberofvalidatedsdfilerecords,
                        unitInterval: 1,

                    },
                    colorScheme: 'scheme01',
                    seriesGroups:
                        [
                            {
                                type: 'column',
                                
                                columnsGapPercent: numberofsdfilerecords,
                                toolTipFormatSettings: { thousandsSeparator: ',' },



                                series: [
                                    {
                                        dataField: 'value',
                                        
                                        labels: {
                                            visible: true,
                                            verticalAlignment: 'center'

                                        },
                                        colorFunction: function (value, itemIndex, serie, group) {

                                            if (itemIndex == 0) {

                                                return '#00FF00'

                                            } else {

                                                return '#FF0000'



                                            }

                                        }
                                    }
                                ]
                            }
                        ]
                };


                

                
                $('#chartContainervalidationresults').jqxChart(settings);



                // show validation problems window

                if (response.bWarnings) {




                    

                    var validationresultdatabindtogrid = response.validationresultitems.filter((el) => {

                        if (isNotEmpty(el.serrormessages)) {

                            

                            

                            return el;

                        }


                        
                    });


                    



                    var validationitemssource = {

                        datatype: "json",

                        datafields: [


                            { name: 'sdfilerecordindex', type: 'string' },
                            { name: 'compoundid', type: 'string' },

                            { name: 'serrormessages', type: 'string', cellsrenderer: messagesrenderer}

                        ]





                    };

                    validationitemssource.localdata = validationresultdatabindtogrid;

                    var validationitemsdataAdapter = new $.jqx.dataAdapter(validationitemssource);

                    $("#validationresultswindowgrid").jqxGrid({ source: validationitemsdataAdapter });

                    

                    $('#validationresultswindow').jqxWindow('open');


                    $("#validationresultswindowbuttongroup").on('buttonclick', function (event) {
                        var clickedButton = event.args.button;

                        if (clickedButton[0].id === "Continue") {

                            $('#validationresultswindow').jqxWindow('close');

                            RegisterSDFile(fileName, compoundname)

                        } else {

                            $('#validationresultswindow').jqxWindow('close');

                        }



                            
                    });

                    



                } else {

                    RegisterSDFile(fileName, compoundname)
                    

                }






            }
        },

        error: function (xhr, status, exception) {

            $('#jqxLoader').jqxLoader('close');

            alert(this.url + " call error. Message: " + exception);




        }
    });



}


function RegisterSDFile(fileName, compoundname) {

    $("#jqxLoader").jqxLoader({ isModal: true, width: 100, height: 60, imagePosition: 'top', text: 'Register SDFile' });

    $('#jqxLoader').jqxLoader('open');

    $.ajax({

        async: true,

        type: "GET",




        url: chemrpsserviceurlprefix + "RegisterSDFile/" + fileName + "/" + compoundname,



        cache: false,






        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {

            $('#jqxLoader').jqxLoader('close');

            


            if (response.bError) {


                alert(response.fatalerrortext);


            } else {


                $('#chartContainerregistrationresults').show();

                var values = response.items;




                var dummyitem = { "context": null, "value": null }

                values.push(dummyitem);

                values.push(dummyitem);


                var settings = {
                    title: "Registration result",
                    description: "",
                    showLegend: false,
                    showToolTips: false,
                    enableAnimations: true,
                    padding: { left: 20, top: 5, right: 20, bottom: 5 },
                    titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
                    borderLineWidth: 0,
                    source: values,
                    xAxis:
                    {

                        dataField: 'context',
                        gridLines: { visible: false },
                        flip: false,
                        labels:
                        {

                            formatFunction: function (value) {


                                

                                if (isNotEmpty(value)) {

                                    return value;

                                } else {

                                    
                                    return " ";

                                }
                            }
                        }

                    },

                    valueAxis:
                    {

                        visible: false,
                        
                        minValue: 0,
                        maxValue: response.numberofprocessedsdfilerecords,
                        unitInterval: 1,
                        labels: {
                            visible: true,
                            formatFunction: function (value) {
                                return value;
                            }
                        }
                    },
                    colorScheme: 'scheme01',
                    seriesGroups:
                        [
                            {
                                type: 'column',
                                
                                columnsGapPercent: numberofsdfilerecords,
                                toolTipFormatSettings: { thousandsSeparator: ',' },
                                series: [
                                    {
                                        dataField: 'value',
                                        
                                        labels: {
                                            visible: true,
                                            verticalAlignment: 'center'

                                        },
                                        colorFunction: function (value, itemIndex, serie, group) {

                                            if (itemIndex == 0) {

                                                return '#00FF00'

                                            } else if (itemIndex == 1) {


                                                return '#00FFCC'


                                            } else {

                                                return '#FF0000'
                                            }

                                        }
                                    }
                                ]
                            }
                        ]
                };

                $('#chartContainerregistrationresults').jqxChart(settings);


                

                ShowRegistrationresultswindow(response);


                



            }
        },

        error: function (xhr, status, exception) {

            $('#jqxLoader').jqxLoader('close');

            alert(this.url + " call error. Message: " + exception);




        }
    });




}

var svgrenderer = function (row, column, value) {

    
    return '<div style="transform: scale(0.5);transform-origin: top center; height: 100px;  width: 200px">' + value + '</div>';
}


var messagesrenderer = function (row, column, value) {

    

    return '<div>' + value.replace(/\n/g, "<br/>") + '</div>';
}



function ShowRegistrationresultswindow(response) {


    





    var compounditemssource = {

        datatype: "json",

        datafields: [


            { name: 'compoundname', type: 'string' },
            { name: 'picture', type: 'string' },
            { name: 'molweight', type: 'number' },
            { name: 'sumformula', type: 'string' },
            { name: 'swarningmessages', type: 'string' },
            { name: 'serrormessages', type: 'string' }

        ]





    };


    var registrationresultdatabindtogrid = response.processedsdfilerecords;

    


    

    compounditemssource.localdata = response.processedsdfilerecords;

    var compounditemsdataAdapter = new $.jqx.dataAdapter(compounditemssource);

    


    $("#registrationresultswindowgrid").jqxGrid({ source: compounditemsdataAdapter });


    $('#registrationresultswindow').jqxWindow('open');


   





}

$(document).ready(function () {

    

    $("#registrationresultswindowgrid").jqxGrid({

        

        width: '100%',



        


        selectionmode: 'singlecell',


        columnsresize: true,

        

        rowsheight: 100,


        height: '100%',


        

        columns: [
            { text: 'ID', datafield: 'compoundname', width: 100 },
            { text: 'Structure', datafield: 'picture', cellsrenderer: svgrenderer, width: 200 },
            { text: 'Molweight', datafield: 'molweight', width: 100 },
            { text: 'Formula', datafield: 'sumformula', width: 100 },
            { text: 'Warnings', datafield: 'swarningmessages', cellsrenderer: messagesrenderer, width: 400 },
            { text: 'Errors', datafield: 'serrormessages', cellsrenderer: messagesrenderer }


        ]








    });



    

    $('#chartcontainer').hide();


    var jqxWidget = $('#body');
    var offset = jqxWidget.offset();

    $('#validationresultswindow').jqxWindow({

        autoOpen: false,

        

        isModal: true,

        showCloseButton: false,

        
        height: '80%',
        width: '80%',

        title: 'Validation problems',

        initContent: function () {




            $("#validationresultswindowgrid").jqxGrid({

                

                width: '100%',



                

                selectionmode: 'singlecell',

                

                columnsresize: true,

                

                rowsheight: 200,


                height: '90%',


                

                columns: [
                    { text: 'SDFile record', datafield: 'sdfilerecordindex', width: 250 },
                    { text: 'Compound ID', datafield: 'compoundid', width: 100 },
                    
                    
                    { text: 'Errors', datafield: 'serrormessages' }


                ]








            });


            $("#validationresultswindowbuttongroup").jqxButtonGroup({ mode: 'default' });

            


        }
    });


    $('#registrationresultswindow').jqxWindow({

        autoOpen: false,

        

        isModal: true,

        
        height: '80%',
        width: '80%',

        title: 'Registration results',

        initContent: function () {

            
            







        }
    });
























   
    $("#sdfilefieldnameswindowlistbox").on('checkChange', function (event) {

        
        

        var args = event.args;
        // get new check state.
        var checked = args.checked;

        if (checked) {

            var checkeditem = args.item;
            var checkeditemLabel = checkeditem.label;
            var checkeditemValue = checkeditem.value;

            
            var checkeditems = $("#sdfilefieldnameswindowlistbox").jqxListBox('getCheckedItems');



            if (isNotEmpty(checkeditems)) {

                for (var currentlycheckeditem in checkeditems) {

                    var mycheckeditem = checkeditems[currentlycheckeditem]

                    if (mycheckeditem.value !== checkeditemValue) {

                        $("#sdfilefieldnameswindowlistbox").jqxListBox('uncheckItem', mycheckeditem);



                    }
                }

                

                

            }




        }




    });

    

    $('#sdfilefieldnameswindow').on('open', function (event) {


        var sdfilefieldnamesdataAdapter = new $.jqx.dataAdapter(sdfilefieldnamessource);

        $("#sdfilefieldnameswindowlistbox").jqxListBox({ width: '100%', source: sdfilefieldnamesdataAdapter, checkboxes: true, height: 400, enableSelection: true, multiple: false });

        

    });

    var jqxWidget = $('#body');
    var offset = jqxWidget.offset();

    $("#sdfilefieldnameswindow").jqxWindow({

        

        width: 500,

        height: 500,

        

        isModal: true,


        autoOpen: false,

        




        initContent: function () {

            

            $('#btn_sdfilefieldnameswindow_OK').click(function () {

                var checkeditems = $("#sdfilefieldnameswindowlistbox").jqxListBox('getCheckedItems');

                var arrayLength = checkeditems.length;

                if (arrayLength > 1) {


                    alert("You can select only one item")
                } else if (arrayLength == 0) {


                    alert("You need to select one item")
                } else {

                    var checkeditem = checkeditems[0]







                    $("#sdfilefieldnameswindow").jqxWindow('close');






                    fileName = uploadedfilename;


                    var compoundname = checkeditem.value;


                    if (!isNotEmpty(fileName)) {


                        alert("Uploaded file name not found when calling registration routine")
                    } else if (!isNotEmpty(compoundname)) {

                        alert("Compound ID not found when calling registration routine")
                    } else {


                        ValidateSDFile(fileName, compoundname)






                    }



                }

            });

            $('#btn_sdfilefieldnameswindow_OK').jqxButton({ width: '70px' });

            $('#btn_sdfilefieldnameswindow_CANCEL').click(function () {

                $('#sdfilefieldnameswindow').jqxWindow('close');

            });

            $('#btn_sdfilefieldnameswindow_CANCEL').jqxButton({ width: '70px' });
            





        }
    });

    



    var jqxFileUploadlabeltext = "Please click the 'Browse' button to select the SDFile you want to register.\n\nNote: Upload files must have extension .sdf and must be of type text.";

    jqxFileUploadlabeltext = jqxFileUploadlabeltext.replace(/\n/g, '<br/>');


    $('#jqxFileUploadlabel').html(jqxFileUploadlabeltext);










    $('#jqxFileUpload').jqxFileUpload({ accept: '.sdf', uploadUrl: 'uploadsdfile.php', fileInputName: 'fileToUpload', multipleFilesUpload: false });
    

    $('#jqxFileUpload').on('select', function (event) {



        




        var args = event.args;
        var fileName = args.file;

        

        var fileSize = args.size;


        var fileExtension = fileName.substring(fileName.lastIndexOf('.') + 1);




        

        if (fileExtension == fileName) {

            alert("File has no extension");

            $('#jqxFileUpload').jqxFileUpload('cancelAll');


        } else {

            fileExtension = fileExtension.toString().toLowerCase();

            if (fileExtension !== "sdf") {


                alert("File must have extension sdf");

                $('#jqxFileUpload').jqxFileUpload('cancelAll');


            } else {

                if (!isNotEmpty(fileSize)) {


                    alert("File is empty");

                    $('#jqxFileUpload').jqxFileUpload('cancelAll');


                } 




            }



        }


        



        



    });

    $('#jqxFileUpload').on('remove', function (event) {

        var fileName = event.args.file;

    });

    $('#jqxFileUpload').on('uploadStart', function (event) {

        var fileName = event.args.file;

        $('#chartcontainer').hide();

        $('#numberofsdfilerecords').hide();

        $('#chartContainervalidationresults').hide();

        $('#chartContainerregistrationresults').hide();




















        $("#jqxLoader").jqxLoader({ isModal: true, width: 100, height: 60, imagePosition: 'top' });

        $('#jqxLoader').jqxLoader('open');
        

    });


    $('#jqxFileUpload').on('uploadEnd', function (event) {

        
        


        $('#jqxLoader').jqxLoader('close');


        var args = event.args;
        var fileName = args.file;

        


        var serverResponce = args.response;

       

        if (serverResponce.startsWith("filename_")) {

            

            fileName = serverResponce.replace("filename_", "");

            uploadedfilename = fileName;

           
            

            


            






            

            $.ajax({

                async: false,

                type: "GET",


                url: "http://SERVERNAME:5003/api/chemrps/GetchemrpsserviceURLPrefixinfo",

                



                contentType: "application/json; charset=utf-8",

                dataType: "json",

                cache: false,







                success: function (response) {





                    

                    if (response.bError) {

                        alert(response.errortext)


                    } else {


                        
                        chemrpsserviceurlprefix = response.chemrpsserviceurlprefix;


                        

                        $.ajax({

                            async: true,

                            type: "GET",




                            url: chemrpsserviceurlprefix + "GetSDFileExternalfieldnames/" + fileName,



                            cache: false,






                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {


                                


                                if (response.bError) {


                                    alert(response.errortext);


                                } else {

                                    


                                    numberofsdfilerecords = response.numberofsdfilerecordsfound;


                                    



                                    


                                    $('#chartcontainer').show();

                                    $('#numberofsdfilerecords').show();

                                    

                                    $('#numberofsdfilerecords').text('Number of SDFile records found: ' + numberofsdfilerecords);

                                    

                                    sdfilefieldnamessource = response.externalfieldnames;

                                    $("#sdfilefieldnameswindow").jqxWindow('open');

                                    

                                    



                                }
                            },

                            error: function (xhr, status, exception) {



                                alert(this.url + " call error. Message: " + exception);




                            }
                        });






                    }


                },
                error: function (xhr, status, exception) {



                    alert(this.url + " call error. Message: " + exception);


                }
            });



            


                

        } else {

            alert("Error. Message: " + serverResponce)

        }


    });





});